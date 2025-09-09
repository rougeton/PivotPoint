import SwiftUI

// This is a test view to verify HeaderView is accessible
struct TestHeaderView: View {
    var body: some View {
        ZStack(alignment: .top) {
            HeaderView()
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                Spacer(minLength: 200)
                Text("Test Header View")
                Spacer()
            }
        }
    }
}

#Preview {
    TestHeaderView()
}
