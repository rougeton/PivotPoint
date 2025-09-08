import SwiftUI

/// View for editing user profile information
struct UserInfoEntryView: View {
    @EnvironmentObject var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Form content with proper spacing
            Form {
                // Spacer section to push content below header
                Section(header: Spacer(minLength: 200)) {
                    EmptyView()
                }

                Section(header: Text("User Information")) {
                    TextField("Full Name", text: $userSettings.userName)
                    TextField("Call Sign", text: $userSettings.callSign)
                    TextField("Crew / Company", text: $userSettings.crewName)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
