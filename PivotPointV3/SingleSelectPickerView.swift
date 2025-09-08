import SwiftUI

struct SingleSelectPickerView: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Custom title area below header
            VStack(spacing: 0) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.top, 200) // Space for header
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)

                // List content
                List(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        dismiss()
                    }) {
                        HStack {
                            Text(option)
                            Spacer()
                            if selectedOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .buttonStyle(PressedHighlightButtonStyle())
                    .foregroundColor(.primary)
                    .listRowBackground(selectedOption == option ? Color.accentColor.opacity(0.35) : Color(uiColor: .systemBackground))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
    }
}
