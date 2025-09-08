import SwiftUI

struct SAOSectionView: View {
    @ObservedObject var report: DTAReport
    
    var body: some View {
        Section("SAO (Safety Assessment Overview)") {
            VStack(alignment: .leading, spacing: 4) {
                Text("SAO Overview").font(.caption).foregroundColor(.secondary)
                TextField("Enter SAO overview", text: $report.saoOverview.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            Toggle("SAO Briefed to Crew", isOn: $report.saoBriefedToCrew)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("SAO Comment").font(.caption).foregroundColor(.secondary)
                TextField("Enter SAO comment", text: $report.saoComment.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Area Safe for Work Comment").font(.caption).foregroundColor(.secondary)
                TextField("Enter area safety comment", text: $report.areaSafeForWorkComment.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            Toggle("Area Between Points Safe for Work", isOn: $report.areaBetweenPointsSafeForWork)
        }
    }
}
