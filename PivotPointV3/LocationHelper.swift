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
