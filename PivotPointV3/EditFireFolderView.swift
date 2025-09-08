import SwiftUI

struct EditFireFolderView: View {
    @ObservedObject var fireFolder: FireFolder
    @Environment(\.dismiss) private var dismiss
    
    @State private var fireNumber: String
    
    init(fireFolder: FireFolder) {
        self.fireFolder = fireFolder
        _fireNumber = State(initialValue: fireFolder.fireNumber ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Edit Fire Number") {
                    TextField("Fire Number", text: $fireNumber)
                }
            }
            .navigationTitle("Edit Fire")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAndDismiss() }
                        .disabled(fireNumber.isEmpty)
                }
            }
        }
    }
    
    private func saveAndDismiss() {
        fireFolder.fireNumber = fireNumber
        fireFolder.folderName = "Fire \(fireNumber)"
        
        do {
            try fireFolder.managedObjectContext?.save()
            dismiss()
        } catch {
            print("Failed to save edited fire folder: \(error)")
        }
    }
}
