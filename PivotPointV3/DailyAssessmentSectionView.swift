import SwiftUI

struct DailyAssessmentSectionView: View {
    // This view now only depends on the ViewModel, making it simpler and more stable.
    @ObservedObject var viewModel: DTAReportViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showSAOBriefingAlert = false

    var body: some View {
        Section("Daily Assessment") {
            NavigationLink(destination: SingleSelectPickerView(title: "SAO Overview", options: DTAPicklists.saoOverviewOptions, selectedOption: $viewModel.saoOverview)) {
                HStack {
                    Text("SAO Overview")
                    Spacer()
                    Text(viewModel.saoOverview).lineLimit(1).foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.saoOverview.isEmpty ? .primary : .green)
            .onChange(of: viewModel.saoOverview) { _, newValue in
                if newValue == "Yes" {
                    viewModel.saoComment = ""
                }
            }
             
            if viewModel.saoOverview == "No" {
                VStack(alignment: .leading) {
                    Text("Explain why:").font(.caption)
                    TextEditor(text: $viewModel.saoComment)
                        .frame(height: 100)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }
            }
            
            if viewModel.saoOverview == "Yes" {
                Toggle("SAO Briefed to Crew?", isOn: $viewModel.saoBriefedToCrew)
                    .foregroundColor(viewModel.saoBriefedToCrew ? .green : .primary)
                    .onChange(of: viewModel.saoBriefedToCrew) { _, isBriefed in
                        if !isBriefed {
                            showSAOBriefingAlert = true
                        }
                    }
                    .alert("Crew Briefing Required", isPresented: $showSAOBriefingAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("Please go brief your crew before proceeding.")
                    }
            }
            
            MultiSelectPicker(title: "Primary Hazards Present", options: DTAPicklists.primaryHazardsPresentOptions, selection: $viewModel.primaryHazardsPresent)
                .foregroundColor(viewModel.primaryHazardsPresent.isEmpty ? .primary : .green)
            
            MultiSelectPicker(title: "Activity", options: DTAPicklists.activityOptions, selection: $viewModel.activity)
                .foregroundColor(viewModel.activity.isEmpty ? .primary : .green)

            NavigationLink(destination: SingleSelectPickerView(title: "Level of Disturbance", options: DTAPicklists.levelOfDisturbanceOptions, selection: $viewModel.levelOfDisturbance)) {
                HStack {
                    Text("Level of Disturbance (LOD)")
                    Spacer()
                    Text(viewModel.levelOfDisturbance).lineLimit(1).foregroundColor(.secondary)
                }
                .foregroundColor(viewModel.levelOfDisturbance.isEmpty ? .primary : .green)
            }
            
            if viewModel.levelOfDisturbance == "1-Low" {
                MultiSelectPicker(title: "LOD Low Hazards", options: DTAPicklists.lodLowHazardsOptions, selection: $viewModel.lodLowHazards)
                    .foregroundColor(viewModel.lodLowHazards.isEmpty ? .primary : .green)
            } else {
                HStack {
                    Text("LOD Low Hazards")
                    Spacer()
                    Text("Not Applicable")
                        .foregroundColor(.green)
                }
            }

            if viewModel.levelOfDisturbance == "2-Medium" {
                MultiSelectPicker(title: "LOD Medium (Fir,Larch,Pine,Spruce)", options: DTAPicklists.lodMediumFirLarchPineSpruceOptions, selection: $viewModel.lodMediumFirLarchPineSpruce)
                    .foregroundColor(viewModel.lodMediumFirLarchPineSpruce.isEmpty ? .primary : .green)
            } else {
                HStack {
                    Text("LOD Medium (Fir,Larch,Pine,Spruce)")
                    Spacer()
                    Text("Not Applicable")
                        .foregroundColor(.green)
                }
            }

            if viewModel.levelOfDisturbance == "2-Medium" {
                MultiSelectPicker(title: "LOD Medium - Red & Yellow Cedar", options: DTAPicklists.lodMediumRedYellowCedarOptions, selection: $viewModel.lodMediumRedYellowCedar)
                    .foregroundColor(viewModel.lodMediumRedYellowCedar.isEmpty ? .primary : .green)
            } else {
                HStack {
                    Text("LOD Medium - Red & Yellow Cedar")
                    Spacer()
                    Text("Not Applicable")
                        .foregroundColor(.green)
                }
            }
                
            NavigationLink(destination: FuelTypeSelectionView(report: viewModel.report, context: viewModel.context)) {
                HStack {
                    Text("Fuel Type")
                    Spacer()
                    Text(viewModel.fuelTypesSummary)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .foregroundColor(viewModel.fuelTypesArray.isEmpty ? .primary : .green)
            }
        }
    }
}
