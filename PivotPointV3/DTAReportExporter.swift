import Foundation
import CoreData

class DTAReportExporter {
    func generateKML(for report: DTAReport) -> String {
        print("Generating KML for report: \(report.unwrappedReportTitle), ID: \(report.id?.uuidString ?? "nil")")
        let waypoints = report.waypointsArray
        print("Report has \(waypoints.count) waypoints")
        
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(sanitizeXMLString(report.unwrappedReportTitle))</name>
        """
        
        for waypoint in waypoints {
            guard let label = waypoint.label else {
                print("Skipping waypoint with nil label: ID=\(waypoint.id?.uuidString ?? "nil")")
                continue
            }
            print("Exporting waypoint: label=\(label), lat=\(waypoint.latitude), lon=\(waypoint.longitude), isSpot=\(waypoint.isSpotPoint)")
            kml += """
              <Placemark>
                <name>\(sanitizeXMLString(label))</name>
                <Point>
                  <coordinates>\(waypoint.longitude),\(waypoint.latitude),0</coordinates>
                </Point>
              </Placemark>
            """
        }
        
        kml += """
          </Document>
        </kml>
        """
        
        print("Generated KML:\n\(kml)")
        return kml
    }
  
    // --- FIX: Renamed this function for clarity ---
    func generateKMLForMultiple(for reports: [DTAReport], title: String) -> String {
        print("Generating KML for \(reports.count) reports, title: \(title)")
        var kml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2">
          <Document>
            <name>\(sanitizeXMLString(title))</name>
        """
        
        for report in reports {
            let waypoints = report.waypointsArray
            print("Processing report: \(report.unwrappedReportTitle), ID: \(report.id?.uuidString ?? "nil"), \(waypoints.count) waypoints")
            
            for waypoint in waypoints {
                guard let label = waypoint.label else {
                    print("Skipping waypoint with nil label: ID=\(waypoint.id?.uuidString ?? "nil")")
                    continue
                }
                print("Exporting waypoint: label=\(label), lat=\(waypoint.latitude), lon=\(waypoint.longitude), isSpot=\(waypoint.isSpotPoint)")
                kml += """
                  <Placemark>
                    <name>\(sanitizeXMLString("\(report.unwrappedReportTitle) - \(label)"))</name>
                    <Point>
                      <coordinates>\(waypoint.longitude),\(waypoint.latitude),0</coordinates>
                    </Point>
                  </Placemark>
                """
            }
        }
        
        kml += """
          </Document>
        </kml>
        """
        
        print("Generated KML for multiple reports:\n\(kml)")
        return kml
    }
    
    private func sanitizeXMLString(_ input: String) -> String {
        var sanitized = input
        let invalidCharacters = ["&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&apos;"]
        for (invalid, replacement) in invalidCharacters {
            sanitized = sanitized.replacingOccurrences(of: invalid, with: replacement)
        }
        return sanitized
    }
}
