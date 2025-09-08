import SwiftUI

struct LevelOfDisturbanceSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel

    var body: some View {
        Section("Level of Disturbance") {
            NavigationLink(destination: SingleSelectPickerView(
                title: "Level of Disturbance",
                options: DTAPicklists.levelOfDisturbanceOptions,
                selectedOption: $viewModel.levelOfDisturbance
            )) {
                HStack {
                    Text("Select Level")
                    Spacer()
                    Text(viewModel.levelOfDisturbance.isEmpty ? "Select..." : viewModel.levelOfDisturbance)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.levelOfDisturbance.isEmpty ? .primary : .green)

            if viewModel.levelOfDisturbance == "High" {
                lodHighInfoBox
            }

            if !viewModel.levelOfDisturbance.isEmpty {
                // MODIFIED: This now uses a MultiSelectPickerView
                NavigationLink(destination: MultiSelectPickerView(
                    title: "LoD Low Hazards",
                    options: DTAPicklists.lodLowHazardsOptions,
                    selection: $viewModel.lodLowHazardsSet
                )) {
                    HStack {
                        Text("LoD Low Hazards")
                        Spacer()
                        Text(lodLowHazardsSummary)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.levelOfDisturbance == "VLR" || viewModel.levelOfDisturbance == "High" || viewModel.levelOfDisturbance == "Moderate")
                .foregroundColor(viewModel.lodLowHazardsSet.isEmpty && !["VLR", "High", "Moderate"].contains(viewModel.levelOfDisturbance) ? .primary : .green)

                NavigationLink(destination: SingleSelectPickerView(
                    title: "LoD Moderate (Fir/Larch/Pine/Spruce)",
                    options: DTAPicklists.lodMediumFirLarchPineSpruceOptions,
                    selectedOption: $viewModel.lodMediumFirLarchPineSpruce
                )) {
                    HStack {
                        Text("LoD Moderate (Fir/Larch/Pine/Spruce)")
                        Spacer()
                        Text(viewModel.lodMediumFirLarchPineSpruce.isEmpty ? "Select..." : viewModel.lodMediumFirLarchPineSpruce)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.levelOfDisturbance == "VLR" || viewModel.levelOfDisturbance == "Low" || viewModel.levelOfDisturbance == "High")
                .foregroundColor(viewModel.lodMediumFirLarchPineSpruce.isEmpty && !["VLR", "Low", "High"].contains(viewModel.levelOfDisturbance) ? .primary : .green)

                NavigationLink(destination: SingleSelectPickerView(
                    title: "LoD Moderate (Red/Yellow Cedar)",
                    options: DTAPicklists.lodMediumRedYellowCedarOptions,
                    selectedOption: $viewModel.lodMediumRedYellowCedar
                )) {
                    HStack {
                        Text("LoD Moderate (Red/Yellow Cedar)")
                        Spacer()
                        Text(viewModel.lodMediumRedYellowCedar.isEmpty ? "Select..." : viewModel.lodMediumRedYellowCedar)
                            .foregroundColor(.secondary)
                    }
                }
                .disabled(viewModel.levelOfDisturbance == "VLR" || viewModel.levelOfDisturbance == "Low" || viewModel.levelOfDisturbance == "High")
                .foregroundColor(viewModel.lodMediumRedYellowCedar.isEmpty && !["VLR", "Low", "High"].contains(viewModel.levelOfDisturbance) ? .primary : .green)
            }
        }
    }
    
    private var lodLowHazardsSummary: String {
        if viewModel.report.lodLowHazards == "Not Applicable" {
            return "Not Applicable"
        }
        if viewModel.lodLowHazardsSet.isEmpty {
            return "Select..."
        }
        if viewModel.lodLowHazardsSet.count > 2 {
            return "\(viewModel.lodLowHazardsSet.count) selected"
        }
        return viewModel.lodLowHazardsSet.sorted().joined(separator: ", ")
    }
    
    private var lodHighInfoBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LOD High: S = Safe").font(.headline).bold()
            Text("If a tree is one of the following:")
            VStack(alignment: .leading, spacing: 4) {
                Text("  • class 1 tree (all species)")
                Text("  • class 2 trees with NO structural defects (all species) usually wind- or snow-snapped green trees, very light fire scorching).")
                Text("  • class 2 cedars with LOW failure potential defects (refer to table at right)")
                Text("  • class 3 conifers with NO structural defects (tree recently killed by insects, climate or light intensity fire— these will have no structural damage or decay)")
            }.padding(.leading, 10)
            Text("D = Dangerous : all other trees").bold()
            Text("(fall tree; create a no-work zone; or remove hazardous parts).").italic()
        }
        .font(.caption)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
