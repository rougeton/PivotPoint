// MARK: - ReportDetailsSectionView.swift
import SwiftUI

struct ReportDetailsSectionView: View {
    @Binding var reportTitle: String
    @Binding var comments: String
    @Binding var assessmentStartEndSpot: String

    // Access the assessment options from DTAPicklists
    private var assessmentOptions: [String] {
        DTAPicklists.assessmentStartEndSpotOptions
    }

    var body: some View {
        Section("Report Details") {
            TextField("Report Title (Description)", text: $reportTitle)
            TextEditor(text: $comments)
                .frame(height: 100)

            Picker("Assessment Start, End or Spot", selection: $assessmentStartEndSpot) {
                ForEach(assessmentOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        }
    }
}
