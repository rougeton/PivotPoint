import SwiftUI

struct SAOSectionView: View {
    @Binding var saoOverview: String
    // THIS IS THE FIX: This now correctly expects a Bool
    @Binding var saoBriefedToCrew: Bool

    var body: some View {
        Section("Site Assessment Overview (SAO)") {
            Picker("SAO Overview", selection: $saoOverview) {
                ForEach(DTAPicklists.saoOverviewOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }

            // This is now a Toggle, which works directly with a Bool
            Toggle("SAO Briefed to Crew?", isOn: $saoBriefedToCrew)
        }
    }
}
