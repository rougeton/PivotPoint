import Foundation
import CoreLocation
import SwiftUI

class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationHelper()
    private let manager = CLLocationManager()

    @Published var lastLocation: CLLocation?
    @Published var isLocationReady = false // New property to track GPS readiness

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            lastLocation = newLocation
            
            // Consider location ready if horizontal accuracy is better than 100 meters
            if newLocation.horizontalAccuracy < 100 && !isLocationReady {
                DispatchQueue.main.async {
                    self.isLocationReady = true
                }
            }
        }
    }

    var currentLatitude: Double {
        lastLocation?.coordinate.latitude ?? 0
    }

    var currentLongitude: Double {
        lastLocation?.coordinate.longitude ?? 0
    }
}

extension CLLocation {
    var ddmCoordinateString: String {
        let lat = coordinate.latitude
        let lon = coordinate.longitude

        let latDegrees = Int(abs(lat))
        let latMinutes = (abs(lat) - Double(latDegrees)) * 60
        let latDirection = lat >= 0 ? "N" : "S"

        let lonDegrees = Int(abs(lon))
        let lonMinutes = (abs(lon) - Double(lonDegrees)) * 60
        let lonDirection = lon >= 0 ? "E" : "W"

        return String(format: "%02d°%06.3f'%@ %03d°%06.3f'%@",
                      latDegrees, latMinutes, latDirection,
                      lonDegrees, lonMinutes, lonDirection)
    }
}
