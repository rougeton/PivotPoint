import SwiftUI

struct DailyAssessmentSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    @State private var showCrewBriefingAlert = false
    
    var body: some View {
        Group {
            NavigationLink(destination: SingleSelectPickerView(
                title: "SAO Overview",
                options: DTAPicklists.saoOverviewOptions,
                selectedOption: $viewModel.saoOverview
            )) {
                HStack {
                    Text("SAO Overview")
                    Spacer()
                    Text(viewModel.saoOverview.isEmpty ? "Select..." : viewModel.saoOverview)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.saoOverview.isEmpty ? .primary : .green)
            
            if !viewModel.saoOverview.isEmpty {
                // Only show comment box if SAO is "No"
                if viewModel.saoOverview == "No" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explain why SAO wasn't completed:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $viewModel.saoComment)
                            .frame(height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                }
                
                Toggle("SAO Briefed to Crew", isOn: $viewModel.saoBriefedToCrew)
                    .foregroundColor(viewModel.saoBriefedToCrew ? .green : .primary)
                    .onChange(of: viewModel.saoBriefedToCrew) { _, briefed in
                        if !briefed {
                            showCrewBriefingAlert = true
                        }
                    }
                    .alert("Crew Briefing Required", isPresented: $showCrewBriefingAlert) {
                        Button("OK, I'll brief the crew", role: .cancel) {}
                    } message: {
                        Text("Please ensure you brief the SAO to your crew before proceeding with work.")
                    }
            }
            
            NavigationLink(destination: MultiSelectPickerView(
                title: "Primary Hazards Present",
                options: DTAPicklists.primaryHazardsPresentOptions,
                selection: $viewModel.primaryHazardsPresent
            )) {
                HStack {
                    Text("Primary Hazards Present")
                    Spacer()
                    Text(primaryHazardsSummary)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .foregroundColor(viewModel.primaryHazardsPresent.isEmpty ? .primary : .green)
            
            NavigationLink(destination: SingleSelectPickerViewNoAutoDismiss(
                title: "Activity",
                options: DTAPicklists.activityOptions,
                selectedOption: $viewModel.activity
            )) {
                HStack {
                    Text("Activity")
                    Spacer()
                    Text(activitySummary)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .foregroundColor(viewModel.activity.isEmpty ? .primary : .green)
        }
    }
    
    private var primaryHazardsSummary: String {
        if viewModel.primaryHazardsPresent.isEmpty { return "Select..." }
        if viewModel.primaryHazardsPresent.count > 2 { return "\(viewModel.primaryHazardsPresent.count) selected" }
        return viewModel.primaryHazardsPresent.sorted().joined(separator: ", ")
    }
    
    private var activitySummary: String {
        if viewModel.activity.isEmpty { return "Select..." }
        return viewModel.activity
    }
}

// New picker view that doesn't auto-dismiss
struct SingleSelectPickerViewNoAutoDismiss: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String

    var body: some View {
        List(options, id: \.self) { option in
            Button(action: {
                selectedOption = option
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
