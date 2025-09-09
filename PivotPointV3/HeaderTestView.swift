import SwiftUI

struct HeaderTestView: View {
    var body: some View {
        VStack {
            Text("Testing HeaderView Accessibility")
                .font(.title)
                .padding()
            
            // Try to use HeaderView
            HeaderView()
                .frame(height: 200)
                .background(Color.gray.opacity(0.2))
            
            Spacer()
        }
        .navigationTitle("Header Test")
    }
}

#Preview {
    NavigationView {
        HeaderTestView()
    }
}
