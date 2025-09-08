import SwiftUI
import CoreData

struct ReportDetailsSectionView: View {
    @ObservedObject var report: DTAReport
    
    var body: some View {
        Section("Report Details") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity").font(.caption).foregroundColor(.secondary)
                TextField("Enter activity", text: $report.activity.unwrapped(with: ""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Assessment Start/End/Spot").font(.caption).foregroundColor(.secondary)
                TextField("Enter assessment details", text: $report.assessmentStartEndSpot.unwrapped(with: ""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated Trees Felled").font(.caption).foregroundColor(.secondary)
                Stepper(value: Binding(
                    get: { Int(report.estimatedTreesFelled) },
                    set: { report.estimatedTreesFelled = Int16($0) }
                ), in: 0...1000) {
                    Text("\(report.estimatedTreesFelled)")
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Primary Hazards Present").font(.caption).foregroundColor(.secondary)
                TextField("Enter primary hazards", text: $report.primaryHazardsPresent.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Level of Disturbance").font(.caption).foregroundColor(.secondary)
                TextField("Enter level of disturbance", text: $report.levelOfDisturbance.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Comments").font(.caption).foregroundColor(.secondary)
                TextField("Enter comments", text: $report.comments.unwrapped(with: ""), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
    }
}
