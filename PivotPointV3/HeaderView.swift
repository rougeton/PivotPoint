import SwiftUI

struct HeaderView: View {
    let addAction: (() -> Void)?
    
    init(addAction: (() -> Void)? = nil) {
        self.addAction = addAction
    }

    var body: some View {
        VStack(spacing: 4) {
            Image("HeaderDark")
                .resizable()
                .scaledToFit()
                .frame(height: 350)
            
            Text("PRAEMONITUS PRAEMUNITUS")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .offset(y: -130)
        }
        .offset(y: -90)
        .overlay(alignment: .bottom) {
            if let addAction = addAction {
                HStack {
                    Spacer()
                    Button(action: addAction) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(.thinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal)
                .offset(y: 15)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
