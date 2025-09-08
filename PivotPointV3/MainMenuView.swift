import SwiftUI
import PhotosUI
import CoreData

struct MainMenuView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedWatermark: UIImage? = nil
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showUserInfoEditor = false
    @State private var showMoreOptions = false
    @State private var showMostRecentFireAlert = false
    @State private var mostRecentFireMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Layer 1: Watermark
                GeometryReader { geometry in
                    let watermarkImage = selectedWatermark ?? UIImage(named: "NewAppLogo")
                    
                    if let uiImage = watermarkImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .opacity(0.9)
                            .shadow(color: .white.opacity(0.6), radius: 20)
                            .shadow(color: .orange.opacity(0.3), radius: 40)
                            .shadow(color: .red.opacity(0.2), radius: 10)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            .onLongPressGesture(minimumDuration: 3) { showPhotoPicker = true }
                            .onTapGesture(count: 2) { selectedWatermark = nil }
                    }
                }
                
                // MARK: - Layer 2: Main UI Content
                VStack(spacing: 0) {
                    HeaderView()
                    
                    Spacer()
                    
                    ProfileStatusView()
                        .padding(.bottom, 4)
                    
                    // MARK: - Bottom Footer Menu
                    HStack {
                        // FIXED: All buttons now use a consistent structure.
                        NavigationLink(value: "FireCenterListView") {
                            HoverButtonView(systemImageName: "flame.circle", label: "Fire Logs")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(value: "ReferencesView") {
                            HoverButtonView(systemImageName: "books.vertical", label: "References")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(value: "CertificationView") {
                            HoverButtonView(systemImageName: "checkmark.seal", label: "Certs")
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(value: "ExportView") {
                            HoverButtonView(systemImageName: "square.and.arrow.up", label: "Export")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { showMoreOptions = true }) {
                            HoverButtonView(systemImageName: "ellipsis.circle", label: "More")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .sheet(isPresented: $showUserInfoEditor) { UserInfoEntryView().environmentObject(userSettings) }
            .confirmationDialog("More Options", isPresented: $showMoreOptions) {
                Button("Edit User Profile") { showUserInfoEditor = true }
                Button("Go to Most Recent Fire") { goToMostRecentFire() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Most Recent Fire", isPresented: $showMostRecentFireAlert) {
                Button("OK") {}
            } message: {
                Text(mostRecentFireMessage)
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let item = newItem, let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        selectedWatermark = image
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "FireCenterListView":
                    FireCenterListView()
                case "ReferencesView":
                    ReferencesView()
                case "CertificationView":
                    CertificationView()
                case "ExportView":
                    ExportView()
                // Handle fire center names for navigation to FireFolderListView
                case "Cariboo Fire Centre", "Coastal Fire Centre", "Kamloops Fire Centre",
                     "Northwest Fire Centre", "Prince George Fire Centre", "Southeast Fire Centre",
                     "Out of Province":
                    FireFolderListView(fireCenter: value)
                default:
                    EmptyView()
                }
            }
            .navigationDestination(for: FireFolder.self) { folder in
                FireFolderDetailView(fireFolder: folder)
            }
            .navigationDestination(for: DTAReport.self) { report in
                DTAReportView(viewModel: DTAReportViewModel(report: report, parentContext: viewContext, userSettings: userSettings))
            }
        }
    }

    private func goToMostRecentFire() {
        // Find the most recently created fire folder
        let request: NSFetchRequest<FireFolder> = FireFolder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FireFolder.id, ascending: false)]
        request.fetchLimit = 1

        do {
            let folders = try viewContext.fetch(request)
            if let mostRecentFolder = folders.first {
                mostRecentFireMessage = """
                Most Recent Fire:

                Fire Number: \(mostRecentFolder.fireNumber ?? "Unknown")
                Fire Center: \(mostRecentFolder.fireCenter ?? "Unknown")

                Navigate to: Fire Centers → \(mostRecentFolder.fireCenter ?? "Unknown") → \(mostRecentFolder.folderName ?? "Unknown")
                """
                showMostRecentFireAlert = true
            } else {
                mostRecentFireMessage = "No fire folders found. Create a fire folder first."
                showMostRecentFireAlert = true
            }
        } catch {
            mostRecentFireMessage = "Error finding most recent fire: \(error.localizedDescription)"
            showMostRecentFireAlert = true
        }
    }
}

// ProfileStatusView remains unchanged
struct ProfileStatusView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        Text(formattedUserInfo())
            .font(.subheadline)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(.thinMaterial, in: Capsule())
            .padding(.bottom, 8)
    }
    
    private func formattedUserInfo() -> String {
        var parts: [String] = []
        if !userSettings.userName.isEmpty { parts.append(userSettings.userName) }
        if !userSettings.callSign.isEmpty { parts.append(userSettings.callSign) }
        if !userSettings.crewName.isEmpty { parts.append(userSettings.crewName) }
        
        return parts.isEmpty ? "No Profile Set" : parts.joined(separator: " • ")
    }
}
