import SwiftUI

/// Placeholder view for the Reference Library section
struct ReferencesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("📚 Reference Library")
                    .font(.largeTitle)
                    .padding()

                Text("You can later add PDFs, SOPs, guides, etc.")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("References")
        }
    }
}
