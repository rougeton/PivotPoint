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
                     .foregroundColor(selection.isEmpty ? .secondary : .primary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var selectedOptionsText: String {
        if selection.isEmpty { return "Select..." }
        if selection.count > 2 { return "\(selection.count) selected" }
        return selection.sorted().joined(separator: ", ")
    }
}

struct MultiSelectPickerView: View {
    let title: String
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                if selection.contains(option) {
                    selection.remove(option)
                } else {
                    selection.insert(option)
                }
            }) {
                HStack {
                    Text(option).foregroundColor(.primary)
                    Spacer()
                    if selection.contains(option) {
                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}
