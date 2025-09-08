import SwiftUI
import CoreData

struct SaveButtonSectionView: View {
    @ObservedObject var report: DTAReport
    @ObservedObject var fireFolder: FireFolder
    let viewContext: NSManagedObjectContext
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Section {
            Button(action: saveReport) {
                HStack {
                    Spacer()
                    Text("Save Report")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .alert("Save Status", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveReport() {
        do {
            // Ensure proper relationship setup
            if report.fireFolder != fireFolder {
                report.fireFolder = fireFolder
                fireFolder.addToDtaReports(report)
            }
            
            // Set default values if needed
            if report.id == nil {
                report.id = UUID()
            }
            
            try viewContext.save()
            alertMessage = "Report saved successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to save report: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}
