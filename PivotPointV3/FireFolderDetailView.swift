import SwiftUI
import CoreData

struct FireFolderDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    @ObservedObject var fireFolder: FireFolder
    
    @State private var activeViewModel: DTAReportViewModel?
    @State private var showReportTypeSheet = false
    @State private var showEditSheet = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Main content with proper spacing
            VStack(spacing: 0) {
                // Custom title area below header with repositioned buttons
                HStack {
                    Button("Edit") { showEditSheet = true }
                        .foregroundColor(.blue)

                    Spacer()

                    Text(fireFolder.fireNumber ?? "Untitled Fire")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    Button("Add") { showReportTypeSheet = true }
                        .foregroundColor(.blue)
                }
                .padding(.top, 200) // Space for header
                .padding(.bottom, 16)
                .padding(.horizontal)
                .background(.regularMaterial)

                // List content
                List {
                    ForEach(fireFolder.dtaReportsArray) { report in
                        NavigationLink(value: report) {
                            Text(report.unwrappedReportTitle)
                        }
                    }
                    .onDelete(perform: deleteReports)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .sheet(isPresented: $showReportTypeSheet) {
            ReportTypeSelectionSheet(
                fireFolder: fireFolder,
                onSelection: { reportType in
                    if reportType == "Create New DTA Report" {
                        if let newReport = createNewDtaReport() {
                            self.activeViewModel = DTAReportViewModel(report: newReport, parentContext: viewContext, userSettings: userSettings)
                        }
                    }
                    showReportTypeSheet = false
                }
            )
        }
        .sheet(isPresented: $showEditSheet) {
            EditFireFolderView(fireFolder: fireFolder)
        }
        // This destination handles navigating to a NEWLY created report
        .navigationDestination(item: $activeViewModel) { viewModel in
            DTAReportView(viewModel: viewModel)
        }
    }
    
    private func deleteReports(at offsets: IndexSet) {
        for index in offsets {
            let report = fireFolder.dtaReportsArray[index]
            viewContext.delete(report)
        }
        try? viewContext.save()
    }
    
    private func createNewDtaReport() -> DTAReport? {
        let newReport = DTAReport(context: viewContext)
        newReport.id = UUID()
        newReport.manualDateTime = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        // Use new format: DTA-(date)-(Activity) - Activity will be updated when entered
        newReport.reportTitle = "DTA-\(dateString)-NoActivity"

        newReport.fireFolder = fireFolder
        newReport.fireCenter = fireFolder.fireCenter
        newReport.fireNumber = fireFolder.fireNumber ?? ""
        newReport.assessedBy = userSettings.userName

        // Set required locationDDM field with current location or default
        let lat = LocationHelper.shared.currentLatitude
        let lon = LocationHelper.shared.currentLongitude
        if lat != 0 && lon != 0 {
            newReport.locationDDM = LocationHelper.shared.lastLocation?.ddmCoordinateString ?? "00°00.000'N 000°00.000'W"
        } else {
            newReport.locationDDM = "00°00.000'N 000°00.000'W" // Default placeholder
        }

        // Set required assessmentStartEndSpot field
        newReport.assessmentStartEndSpot = ""

        // Set required assessmentStartEndSpot field with default value
        newReport.assessmentStartEndSpot = "Not Set"
        
        do {
            try viewContext.save()
            return newReport
        } catch {
            print("Failed to create DTA report: \(error)")
            return nil
        }
    }
}

// ReportTypeSelectionSheet remains unchanged
struct ReportTypeSelectionSheet: View {
    let fireFolder: FireFolder
    let onSelection: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let reportTypes = [
        "Create New DTA Report",
        "Faller Inspection (Coming Soon)",
        "Helipad Inspection (Coming Soon)",
        "Hazard Report (Coming Soon)"
    ]
    
    var body: some View {
        NavigationView {
            List(reportTypes, id: \.self) { reportType in
                Button(action: {
                    if !reportType.contains("Coming Soon") {
                        onSelection(reportType)
                    }
                }) {
                    HStack {
                        Text(reportType)
                            .foregroundColor(reportType.contains("Coming Soon") ? .gray : .primary)
                        Spacer()
                        if reportType.contains("Coming Soon") {
                            Text("Soon")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .disabled(reportType.contains("Coming Soon"))
            }
            .navigationTitle("Select Report Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
