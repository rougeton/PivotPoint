import SwiftUI
import CoreData

struct AddFireFolderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var fireNumber: String = ""
    let fireCenter: String

    var body: some View {
        ZStack {
            HeaderView()
                .frame(maxHeight: .infinity, alignment: .top)
            
            VStack(spacing: 0) {
                // Header with controls
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                    Text("New Fire Log").font(.headline)
                    Spacer()
                    Button("Save") {
                        saveFolder()
                    }
                    .disabled(fireNumber.isEmpty)
                }
                .padding()
                .background(.thinMaterial)

                Form {
                    Section(header: Text("New Fire Details for \(fireCenter)")) {
                        TextField("Fire Number (e.g., G80123)", text: $fireNumber)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 250)
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
    
    private func saveFolder() {
        let newFolder = FireFolder(context: viewContext)
        newFolder.id = UUID()
        newFolder.fireNumber = fireNumber
        newFolder.folderName = "Fire \(fireNumber)"
        newFolder.fireCenter = self.fireCenter
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving FireFolder: \(error)")
        }
    }
}
