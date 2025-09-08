import SwiftUI

/// Placeholder view for the Reference Library section
struct ReferencesView: View {
    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Content with proper spacing
            VStack(spacing: 0) {
                // Spacer for header
                Spacer(minLength: 200)

                VStack {
                    Text("📚 Reference Library")
                        .font(.largeTitle)
                        .padding()

                    Text("You can later add PDFs, SOPs, guides, etc.")
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}
