import Foundation

struct WaypointData: Identifiable, Equatable {
    let id = UUID()
    var latitude: Double
    var longitude: Double
    var locationNotes: String
}
