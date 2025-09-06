import SwiftUI

struct FireCenterListView: View {
    @Environment(\.dismiss) private var dismiss
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
        ZStack {
            HeaderView()
                .environmentObject(userSettings)
                .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("Fire Center")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()
                .background(Color(.systemGray6))

                List(fireCenters, id: \.self) { center in
                    NavigationLink(destination: FireFolderListView(fireCenter: center)) {
                        Text(center)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .padding(.top, 200) // Increased padding to move content down
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}
