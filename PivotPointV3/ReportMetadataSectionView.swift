import SwiftUI

struct ReportMetadataSectionView: View {
    @Binding var assessedBy: String
    @Binding var fireNumber: String
    @Binding var reportTitle: String
    @Binding var dtfCompletedBy: String
    @Binding var fireCenter: String

    var body: some View {
        Section("Report Metadata") {
            HStack {
                Text("Report Title")
                Spacer()
                Text(reportTitle).foregroundColor(.secondary)
            }
            
            HStack {
                Text("Fire Center")
                Spacer()
                Text(fireCenter).foregroundColor(.secondary)
            }
            
            HStack {
                Text("Fire Number")
                Spacer()
                Text(fireNumber).foregroundColor(.secondary)
            }
            
            HStack {
                Text("Assessed By")
                Spacer()
                Text(assessedBy).foregroundColor(.secondary)
            }
            
            TextField("DTF Completed By", text: $dtfCompletedBy)
        }
    }
}
