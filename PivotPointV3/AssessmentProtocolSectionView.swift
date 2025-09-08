import SwiftUI

struct AssessmentProtocolSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    @State private var showNoWorkZoneAlert = false
    @State private var treesFelledTouched: Bool = false
    
    private let reassessmentOptions = ["", "Daily (active burning)", "Every 3 days (active burning)", "Not required"]
    
    private var hasStartAndEndPoints: Bool {
        let labels = Set(viewModel.waypointsArray.map { $0.label ?? "" })
        return labels.contains("Start") && labels.contains("End")
    }

    var body: some View {
        Group {
            NavigationLink(destination: SingleSelectPickerView(
                title: "DTA Marking Protocol",
                options: ["Yes", "No"],
                selectedOption: $viewModel.dtaMarkingProtocolFollowed
            )) {
                HStack {
                    Text("DTA Marking Protocol Followed?")
                    Spacer()
                    Text(viewModel.dtaMarkingProtocolFollowed.isEmpty ? "Select..." : viewModel.dtaMarkingProtocolFollowed)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.dtaMarkingProtocolFollowed.isEmpty ? .primary : .green)
            .onChange(of: viewModel.dtaMarkingProtocolFollowed) { _, newValue in
                if newValue == "Yes" {
                    viewModel.dtaMarkingProtocolComment = ""
                }
            }
            
            if viewModel.dtaMarkingProtocolFollowed == "No" {
                VStack(alignment: .leading) {
                    Text("Indicate what alternative was used:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $viewModel.dtaMarkingProtocolComment)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            HStack {
                Text("Estimated Trees Felled")
                Spacer()
                if treesFelledTouched || viewModel.estimatedTreesFelled > 0 {
                    Text("\(viewModel.estimatedTreesFelled)")
                        .foregroundColor(.green)
                }
                Stepper("Stepper", value: $viewModel.estimatedTreesFelled, in: 0...9999)
                    .labelsHidden()
            }
            .foregroundColor((treesFelledTouched || viewModel.estimatedTreesFelled > 0) ? .green : .primary)
            .onAppear {
                if viewModel.estimatedTreesFelled > 0 {
                    treesFelledTouched = true
                }
            }
            .onChange(of: viewModel.estimatedTreesFelled) { _, _ in
                treesFelledTouched = true
            }

            NavigationLink(destination: SingleSelectPickerView(
                title: "No Work Zones Present?",
                options: ["Yes", "No"],
                selectedOption: $viewModel.noWorkZonesPresent
            )) {
                HStack {
                    Text("No Work Zones Present?")
                    Spacer()
                    Text(viewModel.noWorkZonesPresent.isEmpty ? "Select..." : viewModel.noWorkZonesPresent)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.noWorkZonesPresent.isEmpty ? .primary : .green)

            if viewModel.noWorkZonesPresent == "Yes" {
                Text("Add all No Work Zones as 'Spot' waypoints with photos if possible.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("No Work Zones Identified & Communicated?", isOn: $viewModel.noWorkZones)
                    .foregroundColor(viewModel.noWorkZones ? .green : .primary)
                    .onChange(of: viewModel.noWorkZones) { _, identified in
                        if !identified {
                            showNoWorkZoneAlert = true
                        }
                    }
                    .alert("Communication Required", isPresented: $showNoWorkZoneAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("You must identify and communicate all No Work Zones to your crew.")
                    }
            }

            NavigationLink(destination: SingleSelectPickerView(
                title: "Assessed min. 1.5 TL",
                options: ["Yes", "No"],
                selectedOption: $viewModel.assessedMin1_5TreeLengths
            )) {
                HStack {
                    Text("Assessed min. 1.5 TL from work area")
                    Spacer()
                    Text(viewModel.assessedMin1_5TreeLengths.isEmpty ? "Select..." : viewModel.assessedMin1_5TreeLengths)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.assessedMin1_5TreeLengths.isEmpty ? .primary : .green)
            .onChange(of: viewModel.assessedMin1_5TreeLengths) { _, newValue in
                if newValue == "Yes" {
                    viewModel.assessedTLComment = ""
                }
            }

            if viewModel.assessedMin1_5TreeLengths == "No" {
                VStack(alignment: .leading) {
                    Text("Explain why:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $viewModel.assessedTLComment)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }

            NavigationLink(destination: SingleSelectPickerView(
                title: "Distance from Work Area",
                options: DTAPicklists.assessDistanceFromWorkAreaOptions,
                selectedOption: $viewModel.assessedDistanceFromWorkArea
            )) {
                HStack {
                    Text("Distance from Work Area")
                    Spacer()
                    Text(viewModel.assessedDistanceFromWorkArea.isEmpty ? "Select..." : viewModel.assessedDistanceFromWorkArea)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            .foregroundColor(viewModel.assessedDistanceFromWorkArea.isEmpty ? .primary : .green)
            
            if hasStartAndEndPoints {
                Toggle("Area between start and end safe for work?", isOn: $viewModel.areaBetweenPointsSafeForWork)
                    .foregroundColor(viewModel.areaBetweenPointsSafeForWork ? .green : .primary)
                    .onChange(of: viewModel.areaBetweenPointsSafeForWork) { _, isSafe in
                        if isSafe {
                            viewModel.areaSafeForWorkComment = ""
                        }
                    }
                
                if !viewModel.areaBetweenPointsSafeForWork {
                    VStack(alignment: .leading) {
                        Text("Explain why not:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextEditor(text: $viewModel.areaSafeForWorkComment)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            
            NavigationLink(destination: SingleSelectPickerView(
                title: "Reassessment Needed",
                options: reassessmentOptions.filter { !$0.isEmpty },
                selectedOption: $viewModel.reassessmentNeeded
            )) {
                HStack {
                    Text("Reassessment Needed")
                    Spacer()
                    Text(viewModel.reassessmentNeeded.isEmpty ? "Select..." : viewModel.reassessmentNeeded)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(viewModel.reassessmentNeeded.isEmpty ? .primary : .green)
        }
    }
}
