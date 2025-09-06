import SwiftUI

/// Placeholder view for Certification tracking section
struct CertificationView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("✅ Certification Tracker")
                    .font(.largeTitle)
                    .padding()

                Text("Track chainsaw, faller, or wildfire certifications here.")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("Certification")
        }
    }
}
