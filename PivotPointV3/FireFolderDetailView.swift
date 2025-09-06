import SwiftUI
import CoreData

struct FireFolderDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var fireFolder: FireFolder
    
    @State private var activeViewModel: DTAReportViewModel?
    
    var body: some View {
        List {
            ForEach(fireFolder.dtaReportsArray) { report in
                Button(report.unwrappedReportTitle) {
                    self.activeViewModel = DTAReportViewModel(report: report, parentContext: viewContext, userSettings: userSettings)
                }
            }
        }
        .navigationTitle(fireFolder.fireNumber ?? "Untitled Fire")
        .navigationDestination(item: $activeViewModel) { viewModel in
            DTAReportView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add") {
                    if let newReport = createNewDtaReport() {
                        self.activeViewModel = DTAReportViewModel(report: newReport, parentContext: viewContext, userSettings: userSettings)
                    }
                }
            }
        }
    }
    
    private func createNewDtaReport() -> DTAReport? {
        let newReport = DTAReport(context: viewContext)
        newReport.id = UUID()
        newReport.manualDateTime = Date()
        newReport.reportTitle = "New DTA Report"
        newReport.fireFolder = fireFolder
        newReport.fireCenter = fireFolder.fireCenter
        newReport.fireNumber = fireFolder.fireNumber ?? ""
        // Set default values for all other required fields...
        newReport.assessedBy = ""; newReport.activity = ""; newReport.assessedDistanceFromWorkArea = ""
        newReport.assessedMin1_5TreeLengths = ""; newReport.assessmentStartEndSpot = ""
        newReport.dtaMarkingProtocolFollowed = ""; newReport.levelOfDisturbance = ""
        newReport.locationDDM = ""; newReport.primaryHazardsPresent = ""
        newReport.reassessmentNeeded = ""; newReport.saoOverview = ""
        newReport.areaBetweenPointsSafeForWork = false; newReport.noWorkZones = false; newReport.saoBriefedToCrew = false
        
        do { try viewContext.save(); return newReport }
        catch { print("Failed to create DTA report: \(error)"); return nil }
    }
}
