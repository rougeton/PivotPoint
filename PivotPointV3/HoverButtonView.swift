import SwiftUI

struct HoverButtonView<Destination: View>: View {
    let systemImageName: String
    let label: String
    let destination: Destination
    
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: systemImageName)
                    .font(.title2)
                    .frame(width: 44, height: 44) // Reduced for better fit
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .shadow(radius: isHovered ? 10 : 5)
                
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.primary)
            // This makes each button take up equal space
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8) // Reduced padding
            .onHover { hovering in
                isHovered = hovering
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
