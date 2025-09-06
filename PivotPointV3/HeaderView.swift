import SwiftUI

struct HeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    let showBackButton: Bool
    let addAction: (() -> Void)?
    
    init(showBackButton: Bool = false, addAction: (() -> Void)? = nil) {
        self.showBackButton = showBackButton
        self.addAction = addAction
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(colorScheme == .dark ? "HeaderDark" : "HeaderLight")
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
            // Show the control bar if either a back button or an add action is needed
            if showBackButton || addAction != nil {
                HStack {
                    if showBackButton {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .padding(10)
                                .background(.thinMaterial, in: Circle())
                        }
                    }
                    
                    Spacer()
                    
                    if let addAction = addAction {
                        Button(action: addAction) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .padding(10)
                                .background(.thinMaterial, in: Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .offset(y: 15)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
