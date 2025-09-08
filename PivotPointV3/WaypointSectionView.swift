import SwiftUI
import CoreData
import CoreLocation

struct WaypointSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: DTAReportViewModel
    @StateObject var locationHelper = LocationHelper.shared
    
    @State private var showAddSpotView = false
    @State private var showDeletionAlert = false
    @State private var isAddingWaypoint = false
    @State private var editingWaypoint: DTAWaypoint?

    private var waypoints: [DTAWaypoint] { viewModel.waypointsArray }
    private var hasStartPoint: Bool { waypoints.contains { $0.isStartPoint } }
    private var hasEndPoint: Bool { waypoints.contains { $0.isEndPoint } }

    var body: some View {
        HStack {
            Button("Add Start") { addWaypoint(label: "Start", isStart: true) }
                .buttonStyle(.borderedProminent).tint(.green)
                .disabled(hasStartPoint || isAddingWaypoint)
            
            Button("Add End") { addWaypoint(label: "End", isEnd: true) }
                .buttonStyle(.borderedProminent).tint(.red)
                .disabled(!hasStartPoint || hasEndPoint || isAddingWaypoint)
            
            Button("Add Spot") {
                showAddSpotView = true
            }
            .buttonStyle(.borderedProminent).tint(.orange)
            .disabled(isAddingWaypoint)
        }
        .frame(maxWidth: .infinity)

        ForEach(waypoints) { waypoint in
            HStack {
                Text(waypoint.label ?? "Waypoint").fontWeight(.semibold)
                    .foregroundColor(colorForWaypoint(label: waypoint.label))
                Spacer()
                Text(waypoint.ddmCoordinateString).font(.caption).foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // Only allow editing of spot waypoints
                if waypoint.isSpotPoint {
                    editingWaypoint = waypoint
                }
            }
        }
        .onDelete(perform: deleteWaypoint)
        .alert("Cannot Delete Start Point", isPresented: $showDeletionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You must delete the 'End' point before deleting the 'Start' point.")
        }
        .sheet(isPresented: $showAddSpotView) {
            EnhancedAddSpotWaypointView(report: viewModel.report)
        }
        .sheet(item: $editingWaypoint) { waypoint in
            EditWaypointView(waypoint: waypoint)
        }
    }
    
    private func addWaypoint(label: String, isStart: Bool = false, isEnd: Bool = false) {
        isAddingWaypoint = true
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.label = label
        newWaypoint.latitude = locationHelper.currentLatitude
        newWaypoint.longitude = locationHelper.currentLongitude
        newWaypoint.isStartPoint = isStart
        newWaypoint.isEndPoint = isEnd
        newWaypoint.dtaReport = viewModel.report
        save()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAddingWaypoint = false
        }
    }

    private func addSpotWaypoint() {
        showAddSpotView = true
    }

    private func deleteWaypoint(at offsets: IndexSet) {
        for index in offsets {
            let waypointToDelete = waypoints[index]
            if waypointToDelete.isStartPoint && hasEndPoint {
                showDeletionAlert = true
                return
            }
            viewContext.delete(waypointToDelete)
        }
        save()
    }

    private func save() {
        try? viewContext.save()
    }

    private func colorForWaypoint(label: String?) -> Color {
        guard let label = label else { return .primary }
        if label.starts(with: "Start") { return .green }
        if label.starts(with: "End") { return .red }
        if label.starts(with: "Spot") { return .orange }
        return .primary
    }
}
