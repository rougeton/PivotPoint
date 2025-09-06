import SwiftUI
import CoreData

struct ShareableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct FireFolderListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var showingAddFolder = false
    @State private var editMode: EditMode = .inactive
    @State private var selection = Set<FireFolder>()
    @State private var showDeleteConfirmation = false
    @State private var fileToShare: ShareableFile?
    @State private var showExportError = false
    @State private var exportErrorMessage = ""

    private var fetchRequest: FetchRequest<FireFolder>
    private var folders: FetchedResults<FireFolder> {
        fetchRequest.wrappedValue
    }
    
    let fireCenter: String

    init(fireCenter: String) {
        self.fireCenter = fireCenter
        self.fetchRequest = FetchRequest(
            entity: FireFolder.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \FireFolder.fireNumber, ascending: true)],
            predicate: NSPredicate(format: "fireCenter == %@", fireCenter)
        )
    }

    var body: some View {
        ZStack {
            HeaderView()
                .environmentObject(userSettings)
                .frame(maxHeight: .infinity, alignment: .top)
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(fireCenter)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        showingAddFolder = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))

                List(selection: $selection) {
                    ForEach(folders) { folder in
                        NavigationLink(destination: FireFolderDetailView(fireFolder: folder)) {
                            Text(folder.fireNumber ?? "Untitled Fire")
                        }
                        .onLongPressGesture {
                            withAnimation { self.editMode = .active }
                        }
                    }
                    .onDelete(perform: deleteFolders)
                }
                .listStyle(.insetGrouped)
            }
            .padding(.top, 200)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingAddFolder) { AddFireFolderView(fireCenter: self.fireCenter) }
        .environment(\.editMode, $editMode)
        .toolbar {
            if editMode == .active {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(role: .destructive) {
                        if !selection.isEmpty { showDeleteConfirmation = true }
                    } label: { Image(systemName: "trash") }
                    Spacer()
                    Button("Export") {
                        exportSelectedFolders()
                    }
                    .disabled(selection.isEmpty)
                    Spacer()
                    Button("Done") {
                        withAnimation {
                            self.editMode = .inactive
                            self.selection.removeAll()
                        }
                    }
                }
            }
        }
        .alert("Are you sure?", isPresented: $showDeleteConfirmation) {
            Button("Delete \(selection.count) Item(s)", role: .destructive, action: deleteSelectedFolders)
            Button("Cancel", role: .cancel) {}
        }
        .alert("Export Error", isPresented: $showExportError) {
            Button("OK") { }
        } message: {
            Text(exportErrorMessage)
        }
        .sheet(item: $fileToShare) { file in
            ShareSheet(activityItems: [file.url], completion: {
                try? FileManager.default.removeItem(at: file.url)
                print("Share sheet dismissed, deleted file: \(file.url.path)")
            })
            .onAppear {
                print("Presenting share sheet for file: \(file.url.path)")
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private func exportSelectedFolders() {
        print("Starting KML export for selected folders")
        let exporter = DTAReportExporter()
        let reportsToExport = selection.flatMap { $0.dtaReportsArray }
        
        print("Exporting \(reportsToExport.count) reports")
        guard !reportsToExport.isEmpty else {
            exportErrorMessage = "No reports selected for export."
            showExportError = true
            print("Export failed: No reports")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "\(fireCenter.isEmpty ? "FireCenter" : fireCenter)_Export_\(timestamp).kml"
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // --- FIX: Call the renamed function ---
        let kmlString = exporter.generateKMLForMultiple(for: reportsToExport, title: "\(fireCenter.isEmpty ? "FireCenter" : fireCenter) Export")
        print("Generated KML for multiple reports, preview: \(String(kmlString.prefix(200)))...")
        
        do {
            // --- FIX: Use explicit String.Encoding.utf8 ---
            try kmlString.write(to: tempUrl, atomically: true, encoding: String.Encoding.utf8)
            print("Wrote KML file to: \(tempUrl.path)")
            if FileManager.default.fileExists(atPath: tempUrl.path) {
                let fileSize = (try? FileManager.default.attributesOfItem(atPath: tempUrl.path)[.size] as? Int) ?? 0
                print("File exists with size: \(fileSize) bytes")
                if fileSize > 0 {
                    DispatchQueue.main.async {
                        self.fileToShare = ShareableFile(url: tempUrl)
                    }
                } else {
                    exportErrorMessage = "Generated KML file is empty."
                    showExportError = true
                    print("Export failed: Empty KML file")
                }
            } else {
                exportErrorMessage = "Failed to create KML file."
                showExportError = true
                print("Export failed: File not created")
            }
        } catch {
            exportErrorMessage = "Failed to write KML file: \(error.localizedDescription)"
            showExportError = true
            print("Export failed: \(error)")
        }
    }
    
    private func deleteSelectedFolders() {
        selection.forEach(viewContext.delete)
        saveContext()
        selection.removeAll()
        withAnimation {
            editMode = .inactive
        }
    }

    private func deleteFolders(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(folders[index])
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
            print("Context saved successfully")
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
