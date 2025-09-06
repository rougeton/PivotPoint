import SwiftUI

/// A stylized button used in menus with an icon and title
struct MenuButton: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .imageScale(.large)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.accentColor)
        .cornerRadius(12)
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}
