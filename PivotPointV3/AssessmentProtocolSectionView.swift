import SwiftUI

struct AssessmentProtocolSectionView: View {
    @ObservedObject var report: DTAReport
    
    @Binding var dtaMarkingProtocolFollowed: String
    @Binding var dtaMarkingProtocolComment: String
    @Binding var estimatedTreesFelled: Int16
    @Binding var noWorkZonesPresent: String
    @Binding var noWorkZones: Bool
    @Binding var assessedMin1_5TreeLengths: String
    @Binding var assessedTLComment: String
    @Binding var areaBetweenPointsSafeForWork: Bool
    @Binding var areaSafeForWorkComment: String
    @Binding var reassessmentNeeded: String

    private let reassessmentOptions = ["", "Daily (active burning)", "Every 3 days (active burning)", "Not required"]
    @State private var showNoWorkZoneAlert = false
    @State private var treesFelledTouched: Bool = false
    
    private var hasStartAndEndPoints: Bool {
        let labels = Set(report.waypointsArray.map { $0.label ?? "" })
        return labels.contains("Start") && labels.contains("End")
    }

    var body: some View {
        Section(header: Text("Assessment Protocol")) {
            NavigationLink(destination: SingleSelectPickerView(title: "DTA Marking Protocol", options: ["Yes", "No"], selectedOption: $dtaMarkingProtocolFollowed)) {
                HStack {
                    Text("DTA Marking Protocol Followed?")
                    Spacer()
                    Text(dtaMarkingProtocolFollowed).foregroundColor(.secondary)
                }
            }
            .foregroundColor(dtaMarkingProtocolFollowed.isEmpty ? .primary : .green)
            .onChange(of: dtaMarkingProtocolFollowed) { _, newValue in
                if newValue == "Yes" { dtaMarkingProtocolComment = "" }
            }
            
            if dtaMarkingProtocolFollowed == "No" {
                VStack(alignment: .leading) {
                    Text("Indicate what alternative was used:").font(.caption)
                    TextEditor(text: $dtaMarkingProtocolComment).frame(height: 100)
                }
            }
            
            HStack {
                Text("Estimated Trees Felled")
                Spacer()
                if treesFelledTouched { Text("\(estimatedTreesFelled)") }
                Stepper("Stepper", value: $estimatedTreesFelled, in: 0...9999).labelsHidden()
            }
            .foregroundColor(treesFelledTouched ? .green : .primary)
            .onAppear {
                if estimatedTreesFelled > 0 { treesFelledTouched = true }
            }
            .onChange(of: estimatedTreesFelled) { _, _ in treesFelledTouched = true }

            NavigationLink(destination: SingleSelectPickerView(title: "No Work Zones Present?", options: ["Yes", "No"], selectedOption: $noWorkZonesPresent)) {
                HStack {
                    Text("No Work Zones Present?")
                    Spacer()
                    Text(noWorkZonesPresent).foregroundColor(.secondary)
                }
            }
            .foregroundColor(noWorkZonesPresent.isEmpty ? .primary : .green)

            if noWorkZonesPresent == "Yes" {
                Text("Add all No Work Zones as 'Spot' waypoints with photos if possible.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("No Work Zones Identified & Communicated?", isOn: $noWorkZones)
                    .foregroundColor(noWorkZones ? .green : .primary)
                    .onChange(of: noWorkZones) { _, identified in
                        if !identified { showNoWorkZoneAlert = true }
                    }
                    .alert("Communication Required", isPresented: $showNoWorkZoneAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("You must identify and communicate all No Work Zones to your crew.")
                    }
            }

            NavigationLink(destination: SingleSelectPickerView(title: "Assessed min. 1.5 TL", options: ["Yes", "No"], selectedOption: $assessedMin1_5TreeLengths)) {
                HStack {
                    Text("Assessed min. 1.5 TL from work area")
                    Spacer()
                    Text(assessedMin1_5TreeLengths).foregroundColor(.secondary)
                }
            }
            .foregroundColor(assessedMin1_5TreeLengths.isEmpty ? .primary : .green)
            .onChange(of: assessedMin1_5TreeLengths) { _, newValue in
                if newValue == "Yes" { assessedTLComment = "" }
            }

            if assessedMin1_5TreeLengths == "No" {
                VStack(alignment: .leading) {
                    Text("Explain why:").font(.caption)
                    TextEditor(text: $assessedTLComment).frame(height: 100)
                }
            }
            
            // --- FIX: Replaced Picker with Toggle ---
            if hasStartAndEndPoints {
                Toggle("Area between start and end safe for work?", isOn: $areaBetweenPointsSafeForWork)
                    .onChange(of: areaBetweenPointsSafeForWork) { _, isSafe in
                        if isSafe { areaSafeForWorkComment = "" }
                    }
                
                if !areaBetweenPointsSafeForWork {
                    VStack(alignment: .leading) {
                        Text("Explain why not:").font(.caption)
                        TextEditor(text: $areaSafeForWorkComment).frame(height: 100)
                    }
                }
            }
            
            NavigationLink(destination: SingleSelectPickerView(title: "Reassessment Needed", options: reassessmentOptions.filter { !$0.isEmpty }, selectedOption: $reassessmentNeeded)) {
                HStack {
                    Text("Reassessment Needed")
                    Spacer()
                    Text(reassessmentNeeded).foregroundColor(.secondary)
                }
            }
            .foregroundColor(reassessmentNeeded.isEmpty ? .primary : .green)
        }
    }
}
