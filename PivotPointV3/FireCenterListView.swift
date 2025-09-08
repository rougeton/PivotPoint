import SwiftUI

struct FireCenterListView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    let fireCenters = [
        "Cariboo Fire Centre",
        "Coastal Fire Centre",
        "Kamloops Fire Centre",
        "Northwest Fire Centre",
        "Prince George Fire Centre",
        "Southeast Fire Centre",
        "Out of Province"
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Main content with proper spacing
            VStack(spacing: 0) {
                // Custom title area below header
                Text("Fire Center")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 200) // Space for header
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)

                // List content
                List(fireCenters, id: \.self) { center in
                    NavigationLink(center, value: center)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}
