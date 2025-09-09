import SwiftUI

struct HeaderAccessTestView: View {
    var body: some View {
        VStack {
            Text("HeaderView Access Test")
                .font(.title)
                .padding()
            
            // Try to use HeaderView directly
            HeaderView()
                .frame(height: 100)
                .background(Color.gray.opacity(0.2))
            
            Spacer()
        }
    }
}

#Preview {
    HeaderAccessTestView()
}
