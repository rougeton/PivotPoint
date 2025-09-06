import SwiftUI
import CoreData
import MapKit

struct AssessmentStartEndSpotView: View {
    @ObservedObject var report: DTAReport
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var locationNotes: String = ""
    @State private var isStopPoint: Bool = false
    
    var body: some View {
        Form {
            Section("Waypoint Info") {
                TextField("Notes / Label", text: $locationNotes)
                
                Toggle("Mark as Stop Point?", isOn: $isStopPoint)
            }
            
            Section {
                Button(action: addWaypoint) {
                    Text("Add Waypoint")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Add Waypoint")
    }
    
    private func addWaypoint() {
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.latitude = LocationHelper.shared.currentLatitude
        newWaypoint.longitude = LocationHelper.shared.currentLongitude
        newWaypoint.locationNotes = locationNotes
        newWaypoint.isStopPoint = isStopPoint
        newWaypoint.dtaReport = report  // Changed from 'report' to 'dtaReport'
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save waypoint: \(error.localizedDescription)")
        }
    }
}
