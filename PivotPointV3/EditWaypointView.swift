import SwiftUI
import CoreData

struct EditWaypointView: View {
    @ObservedObject var waypoint: DTAWaypoint
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Form {
            Section("Edit Waypoint Notes") {
                TextEditor(text: Binding(
                    get: { waypoint.locationNotes ?? "" },
                    set: { waypoint.locationNotes = $0 }
                ))
                .frame(height: 200)
            }
        }
        .navigationTitle(waypoint.label ?? "Edit Waypoint")
        .navigationBarTitleDisplayMode(.inline)
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
