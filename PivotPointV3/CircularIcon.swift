import SwiftUI

/// A circular icon with a gradient background and label
struct CircularIcon: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        VStack {
            ZStack {
                // Circular gradient background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.9), color.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 4)

                // Icon on top
                Image(systemName: systemImage)
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .bold))
            }

            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
                .padding(.top, 4)
        }
    }
}
