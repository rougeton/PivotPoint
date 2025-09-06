import SwiftUI

/// Placeholder view for exporting logs, data, and files
struct ExportView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("📤 Export Center")
                    .font(.largeTitle)
                    .padding()

                Text("Export your logs, data, and files from here.")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .navigationTitle("Export")
        }
    }
}
