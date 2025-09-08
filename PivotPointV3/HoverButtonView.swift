import SwiftUI

struct HoverButtonView: View {
    let systemImageName: String
    let label: String

    var body: some View {
        VStack {
            Image(systemName: systemImageName)
                .font(.title2)
                .frame(width: 44, height: 44)
            Text(label)
                .font(.caption)
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
