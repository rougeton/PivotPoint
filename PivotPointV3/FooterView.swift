import SwiftUI

/// Footer view displayed at the bottom of the app
struct FooterView: View {
    var body: some View {
        Text("PRAEMONITUS PRAEMUNITUS")
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            // Reduced padding for a tighter layout
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGroupedBackground).opacity(0.8))
    }
}
