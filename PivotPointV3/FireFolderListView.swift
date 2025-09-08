import SwiftUI
import CoreData

struct FireFolderListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var showAddFireSheet = false
    
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
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Main content with proper spacing
            VStack(spacing: 0) {
                // Custom title area below header
                Text(fireCenter)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 200) // Space for header
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)

                // List content
                List {
                    ForEach(folders) { folder in
                        NavigationLink(value: folder) {
                            Text(folder.folderName ?? "Untitled Fire")
                                .padding(.vertical, 6)
                        }
                    }
                    .onDelete(perform: deleteFolders)
                }
                .listStyle(.insetGrouped)

                Spacer()

                Button(action: { showAddFireSheet = true }) {
                    Text("Add Fire")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .sheet(isPresented: $showAddFireSheet) {
            AddFireFolderView(fireCenter: self.fireCenter)
        }
    }
    
    private func deleteFolders(offsets: IndexSet) {
        for index in offsets {
            // FIXED: Corrected the typo here.
            viewContext.delete(folders[index])
        }
        try? viewContext.save()
    }
}
