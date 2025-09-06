import Foundation
import CoreData

extension DTAReport {
    var unwrappedReportTitle: String {
        reportTitle ?? "Untitled Report"
    }
    
    var mediaAttachmentsArray: [MediaAttachment] {
        let set = mediaAttachments as? Set<MediaAttachment> ?? []
        return set.sorted { ($0.photoTimestamp ?? Date()) < ($1.photoTimestamp ?? Date()) }
    }
    
    var waypointsArray: [DTAWaypoint] {
        let set = waypoints as? Set<DTAWaypoint> ?? []
        return set.sorted { ($0.label ?? "") < ($1.label ?? "") }
    }
}

extension FireFolder {
    var unwrappedName: String {
        folderName ?? "Untitled Fire Folder"
    }
    
    var dtaReportsArray: [DTAReport] {
        let set = dtaReports as? Set<DTAReport> ?? []
        return set.sorted { ($0.manualDateTime ?? Date()) > ($1.manualDateTime ?? Date()) }
    }
}

extension FireCSV {
    var unwrappedFileName: String {
        fileName ?? "Untitled CSV"
    }
}

extension FirePDF {
    var unwrappedFileName: String {
        fileName ?? "Untitled PDF"
    }
}

extension DTAWaypoint {
    var coordinateString: String {
        return String(format: "%.6f, %.6f", latitude, longitude)
    }

    // --- NEW: DDM Coordinate Formatting ---
    var ddmCoordinateString: String {
        let latDegrees = Int(abs(latitude))
        let latMinutes = (abs(latitude) - Double(latDegrees)) * 60
        let latDirection = latitude >= 0 ? "N" : "S"
        
        let lonDegrees = Int(abs(longitude))
        let lonMinutes = (abs(longitude) - Double(lonDegrees)) * 60
        let lonDirection = longitude >= 0 ? "E" : "W"
        
        return String(format: "%d° %.3f' %@, %d° %.3f' %@",
                      latDegrees, latMinutes, latDirection,
                      lonDegrees, lonMinutes, lonDirection)
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
