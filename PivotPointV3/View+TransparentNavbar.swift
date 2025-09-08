import SwiftUI

/// A view modifier to make the navigation bar transparent.
struct TransparentNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let appearance = UINavigationBarAppearance()
                // Configure the appearance to be transparent
                appearance.configureWithTransparentBackground()
                
                // Apply this transparent appearance to all states of the navigation bar
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
            .onDisappear {
                // Restore the default navigation bar appearance when the view is no longer on screen
                let appearance = UINavigationBarAppearance()
                appearance.configureWithDefaultBackground()
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
    }
}

extension View {
    /// Applies a transparent navigation bar to the view.
    func transparentNavigationBar() -> some View {
        self.modifier(TransparentNavigationBar())
    }
}
