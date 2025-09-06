import SwiftUI

struct MultiSelectPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        NavigationLink(destination: MultiSelectPickerView(title: title, options: options, selection: $selection)) {
            HStack {
                Text(title)
                Spacer()
                Text(selectedOptionsText)
                     .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
    }

    private var selectedOptionsText: String {
        if selection.isEmpty { return "None" }
        return selection.sorted().joined(separator: ", ")
    }
}

struct MultiSelectPickerView: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                withAnimation(.bouncy(duration: 0.4)) {
                    if selection.contains(option) {
                        selection.remove(option)
                    } else {
                        selection.insert(option)
                    }
                }
            }) {
                HStack {
                    Text(option)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer()
                    if selection.contains(option) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressedHighlightButtonStyle())
            .foregroundColor(.primary)
            .listRowBackground(selection.contains(option) ? Color.accentColor.opacity(0.35) : Color(uiColor: .systemBackground))
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
