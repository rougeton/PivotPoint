import SwiftUI

/// Observable object to store user settings across the app
class UserSettings: ObservableObject {
    // User information stored in AppStorage for persistence
    @AppStorage("userName") var userName: String = ""
    @AppStorage("callSign") var callSign: String = ""
    @AppStorage("crewName") var crewName: String = ""
    
    // Lock state for app features
    @AppStorage("isLocked") var isLocked: Bool = false
    
    /// Returns true if all required user info fields are filled
    var isComplete: Bool {
        !userName.isEmpty && !callSign.isEmpty && !crewName.isEmpty
    }
}
