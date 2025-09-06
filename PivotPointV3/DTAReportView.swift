import SwiftUI
import CoreData
import PhotosUI

struct DTAReportView: View {
    @StateObject private var viewModel: DTAReportViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSettings: UserSettings

    init(report: DTAReport, parentContext: NSManagedObjectContext, userSettings: UserSettings) {
        self._viewModel = StateObject(wrappedValue: DTAReportViewModel(
            report: report,
            parentContext: parentContext,
            userSettings: userSettings
        ))
    }

    var body: some View {
        Form {
            // Your other sections for editing the report go here
            // e.g., ReportMetadataSectionView, DailyAssessmentSectionView, etc.

            WaypointSectionView(report: viewModel.report)
        }
        .navigationTitle(viewModel.report.unwrappedReportTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    $viewModel.discardChanges
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveContext()
                    dismiss()
                }
            }
        }
        // --- THIS IS THE CRITICAL FIX ---
        // It injects the temporary "draft" context into this view and all its children.
        .environment(\.managedObjectContext, viewModel.context)
    }
}
