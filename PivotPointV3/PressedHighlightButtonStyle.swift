import SwiftUI

// This custom ButtonStyle can now be used by any view in your app.
struct PressedHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.clear)
    }
}
