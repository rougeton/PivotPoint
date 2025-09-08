import SwiftUI
import CoreData
import CoreLocation

struct WaypointsDisplayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var report: DTAReport
    @StateObject private var locationHelper = LocationHelper.shared
    @State private var isShowingSpotSheet = false

    private var waypoints: [DTAWaypoint] {
        (report.waypoints as? Set<DTAWaypoint> ?? []).sorted { $0.label ?? "" < $1.label ?? "" }
    }
    
    private var hasStartPoint: Bool {
        waypoints.contains { $0.isStartPoint }
    }
    
    private var hasEndPoint: Bool {
        waypoints.contains { $0.isEndPoint }
    }

    var body: some View {
        Section("Assessment Waypoints") {
            HStack {
                Button("Add Start") {
                    addWaypoint(label: "Start", isStart: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(hasStartPoint)
                
                Button("Add End") {
                    addWaypoint(label: "End", isEnd: true)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(!hasStartPoint || hasEndPoint)
                
                Button("Add Spot") {
                    showSpotSheet()
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .frame(maxWidth: .infinity)

            ForEach(waypoints) { waypoint in
                HStack {
                    Text(waypoint.label ?? "Waypoint")
                        .fontWeight(.semibold)
                        .foregroundColor(colorForWaypoint(label: waypoint.label))
                    Spacer()
                    Text(waypoint.ddmCoordinateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteWaypoint)
        }
        .sheet(isPresented: $isShowingSpotSheet) {
            SimpleSpotSheet(report: report, onDismiss: {
                isShowingSpotSheet = false
            })
        }
    }
    
    private func showSpotSheet() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isShowingSpotSheet = true
        }
    }
    
    private func addWaypoint(label: String, isStart: Bool = false, isEnd: Bool = false) {
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.label = label
        newWaypoint.latitude = locationHelper.currentLatitude
        newWaypoint.longitude = locationHelper.currentLongitude
        newWaypoint.isStartPoint = isStart
        newWaypoint.isEndPoint = isEnd
        newWaypoint.dtaReport = report
        save()
    }
    
    private func deleteWaypoint(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(waypoints[index])
        }
        save()
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save waypoint: \(error)")
        }
    }
    
    private func colorForWaypoint(label: String?) -> Color {
        guard let label = label else { return .primary }
        if label.starts(with: "Start") { return .green }
        if label.starts(with: "End") { return .red }
        if label.starts(with: "Spot") { return .orange }
        return .primary
    }
}

// Simple spot waypoint sheet to avoid conflicts
struct SimpleSpotSheet: View {
    @ObservedObject var report: DTAReport
    @Environment(\.managedObjectContext) private var viewContext
    let onDismiss: () -> Void
    @State private var comment = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Spot Details") {
                    TextField("Comment (e.g., spot fire, pump site)", text: $comment)
                }
            }
            .navigationTitle("Add Spot Waypoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addSpotWaypoint()
                    }
                }
            }
        }
    }
    
    private func addSpotWaypoint() {
        let spotCount = (report.waypoints as? Set<DTAWaypoint> ?? []).filter {
            $0.label?.starts(with: "Spot") == true
        }.count
        
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.label = "Spot \(spotCount + 1)"
        newWaypoint.latitude = LocationHelper.shared.currentLatitude
        newWaypoint.longitude = LocationHelper.shared.currentLongitude
        newWaypoint.locationNotes = comment
        newWaypoint.isSpotPoint = true
        newWaypoint.dtaReport = report
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save spot waypoint: \(error)")
        }
        
        onDismiss()
    }
}
