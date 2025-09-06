import SwiftUI

/// Animated splash screen with a glowing, pulsing logo.
struct SplashView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            // Glowing, pulsing logo
            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 220)
                // Glow effect
                .shadow(color: .orange.opacity(0.6), radius: animate ? 40 : 20)
                .shadow(color: .red.opacity(0.4), radius: animate ? 60 : 30)
                // Scaling effect for pulse
                .scaleEffect(animate ? 1.1 : 1.0)
                .opacity(animate ? 1.0 : 0.8)
                // Animation that repeats forever
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            animate = true
        }
    }
}
