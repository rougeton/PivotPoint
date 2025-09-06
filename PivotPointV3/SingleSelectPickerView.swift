import SwiftUI

struct SingleSelectPickerView: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
