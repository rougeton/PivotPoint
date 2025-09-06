import SwiftUI

/// View for editing user profile information
struct UserInfoEntryView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Full Name", text: $userSettings.userName)
                    TextField("Call Sign", text: $userSettings.callSign)
                    TextField("Crew / Company", text: $userSettings.crewName)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
