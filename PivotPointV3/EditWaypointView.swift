import SwiftUI
import CoreData

struct EditWaypointView: View {
    @ObservedObject var waypoint: DTAWaypoint
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Form content with proper spacing
            Form {
                // Spacer section to push content below header
                Section(header: Spacer(minLength: 200)) {
                    EmptyView()
                }

                Section("Edit Waypoint Notes") {
                    TextEditor(text: Binding(
                        get: { waypoint.locationNotes ?? "" },
                        set: { waypoint.locationNotes = $0 }
                    ))
                    .frame(height: 200)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .onDisappear {
            // Auto-save any changes when the user navigates back
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save waypoint edits: \(error.localizedDescription)")
                }
            }
        }
    }
}
