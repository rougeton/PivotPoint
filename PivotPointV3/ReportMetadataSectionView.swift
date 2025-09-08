import SwiftUI

struct ReportMetadataSectionView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    
    var body: some View {
        Section("Report Information") {
            // NON-EDITABLE: Auto-generated report title
            VStack(alignment: .leading, spacing: 4) {
                Text("Report Title").font(.caption).foregroundColor(.secondary)
                Text(viewModel.reportTitle)
                    .foregroundColor(.green)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Auto-populated and GREEN
            VStack(alignment: .leading, spacing: 4) {
                Text("Fire Number").font(.caption).foregroundColor(.secondary)
                Text(viewModel.fireNumber.isEmpty ? "N/A" : viewModel.fireNumber)
                    .foregroundColor(.green)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Auto-populated and GREEN
            VStack(alignment: .leading, spacing: 4) {
                Text("Fire Centre").font(.caption).foregroundColor(.secondary)
                Text(viewModel.fireCenter.isEmpty ? "N/A" : viewModel.fireCenter)
                    .foregroundColor(.green)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // NON-EDITABLE: Auto-populated from user profile
            VStack(alignment: .leading, spacing: 4) {
                Text("Assessed By").font(.caption).foregroundColor(.secondary)
                Text(viewModel.assessedBy)
                    .foregroundColor(.green)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("DTF Completed By").font(.caption).foregroundColor(.secondary)
                TextField("Enter DTF completion details", text: $viewModel.dtfCompletedBy)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // NON-EDITABLE: Auto-populated date/time in 24-hour format
            VStack(alignment: .leading, spacing: 4) {
                Text("Assessment Date/Time").font(.caption).foregroundColor(.secondary)
                Text(formatDateTime(viewModel.report.manualDateTime ?? Date()))
                    .foregroundColor(.green)
                    .font(.body)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" // 24-hour format
        return formatter.string(from: date)
    }
}
