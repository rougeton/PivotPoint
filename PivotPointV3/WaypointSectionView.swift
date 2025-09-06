import SwiftUI
import CoreData
import CoreLocation

struct WaypointButtonStyle: ButtonStyle {
    let color: Color
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .foregroundColor(isDisabled ? .secondary : color)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isDisabled ? Color.secondary.opacity(0.6) : color, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct WaypointSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var report: DTAReport
    @StateObject var locationHelper = LocationHelper.shared
    
    @State private var showAddSpotView = false

    private var waypoints: [DTAWaypoint] {
        report.waypointsArray
    }
    
    private var hasStartPoint: Bool {
        waypoints.contains { $0.isStartPoint }
    }
    
    private var hasEndPoint: Bool {
        waypoints.contains { $0.isEndPoint }
    }

    var body: some View {
        Section("Waypoints") {
            HStack(spacing: 12) {
                Button(action: { addWaypoint(label: "Start") }) {
                    Text("Start").fontWeight(.bold).frame(maxWidth: .infinity)
                }
                .buttonStyle(WaypointButtonStyle(color: .green, isDisabled: hasStartPoint))
                .disabled(hasStartPoint)
                
                Button(action: { addWaypoint(label: "End") }) {
                    Text("End").fontWeight(.bold).frame(maxWidth: .infinity)
                }
                .buttonStyle(WaypointButtonStyle(color: .red, isDisabled: hasEndPoint))
                .disabled(hasEndPoint)

                Button(action: { showAddSpotView = true }) {
                    Text("Spot").fontWeight(.bold).frame(maxWidth: .infinity)
                }
                .buttonStyle(WaypointButtonStyle(color: .orange, isDisabled: false))
            }
            .padding(.vertical, 4)

            if waypoints.isEmpty {
                Text("No waypoints added.").foregroundColor(.secondary)
            } else {
                ForEach(waypoints) { waypoint in
                    NavigationLink(destination: EditWaypointView(waypoint: waypoint)) {
                        HStack {
                            Text(waypoint.label ?? "Waypoint")
                                .foregroundColor(colorForWaypoint(label: waypoint.label))
                                .fontWeight(.semibold)

                            if let notes = waypoint.locationNotes, !notes.isEmpty {
                                Text("- \(notes)").lineLimit(1).truncationMode(.tail).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(waypoint.ddmCoordinateString).font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteWaypoint)
            }
        }
        .sheet(isPresented: $showAddSpotView) {
            AddSpotWaypointView(report: report)
        }
    }
    
    private func addWaypoint(label: String) {
        let newWaypoint = DTAWaypoint(context: viewContext)
        newWaypoint.id = UUID()
        newWaypoint.latitude = locationHelper.currentLatitude
        newWaypoint.longitude = locationHelper.currentLongitude
        newWaypoint.label = label
        newWaypoint.dtaReport = report
        newWaypoint.isStartPoint = label.contains("Start")
        newWaypoint.isEndPoint = label.contains("End")
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save waypoint: \(error)")
        }
    }
    
    private func deleteWaypoint(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(waypoints[index])
        }
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete waypoints: \(error)")
        }
    }
    
    private func colorForWaypoint(label: String?) -> Color {
        guard let label = label else { return .primary }
        if label.starts(with: "Start") { return .green }
        else if label.starts(with: "End") { return .red }
        else if label.starts(with: "Spot") { return .orange }
        return .primary
    }
}
