import SwiftUI
import CoreData
import PhotosUI

struct DTAReportView: View {
    @ObservedObject var viewModel: DTAReportViewModel
    
    @State private var fileToShare: ShareableFile?
    @State private var showValidationAlert = false
    @State private var missingFields: [String] = []

    init(viewModel: DTAReportViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background header
            HeaderView()
                .ignoresSafeArea(edges: .top)

            // Form content with proper spacing
            Form {
                // Spacer section to push content below header
                Section(header: Spacer(minLength: 200)) {
                    ReportMetadataSectionView(viewModel: viewModel)
                }
            
            Section("Assessment Waypoints") {
                WaypointSectionView(viewModel: viewModel)
            }
            
            Section("Daily Assessment") {
                DailyAssessmentSectionView(viewModel: viewModel)
            }
            
            Section("Level of Disturbance") {
                LevelOfDisturbanceSectionView(viewModel: viewModel)
            }
            
            Section("Fuel Types") {
                NavigationLink(destination: FuelTypeSelectionView(report: viewModel.report, context: viewModel.context, viewModel: viewModel)) {
                    HStack {
                        Text("Select Fuel Types")
                        Spacer()
                        Text(fuelTypeSummary)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(hasFuelTypes ? .green : .primary)
            }
            
            Section("Assessment Protocol") {
                AssessmentProtocolSectionView(viewModel: viewModel)
            }
            
            Section("Additional Media") {
                PhotosSectionView(viewModel: viewModel)
            }
            
            Section("Additional Comments") {
                CommentsSectionView(comments: $viewModel.comments)
            }
            
            exportButtonsSection
            }
            .listStyle(.insetGrouped)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .onDisappear {
            viewModel.saveContext()
        }
        .environment(\.managedObjectContext, viewModel.context)
        .sheet(item: $fileToShare) { file in
            ShareSheet(activityItems: [file.url]) {
                try? FileManager.default.removeItem(at: file.url)
            }
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please fill out the following required fields before exporting:\n\n• " + missingFields.joined(separator: "\n• "))
        }
    }
    
    private var exportButtonsSection: some View {
        Section("Export Report") {
            HStack(spacing: 12) {
                exportButton(title: "KML", color: .blue, type: .kml)
                exportButton(title: "CSV", color: .green, type: .csv)
                exportButton(title: "PDF", color: .red, type: .pdf)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func exportButton(title: String, color: Color, type: ExportType) -> some View {
        Button(action: { validateAndExport(type: type) }) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .controlSize(.large)
    }
    
    private var fuelTypeSummary: String {
        // Use the published property to ensure UI updates
        _ = viewModel.fuelTypesChanged
        let fuelTypes = viewModel.report.fuelTypes as? Set<FuelTypeSelection> ?? []
        if fuelTypes.isEmpty { return "Select..." }

        let sortedTypes = fuelTypes.sorted { $0.fuelType ?? "" < $1.fuelType ?? "" }

        let abbreviations = sortedTypes.compactMap { selection -> String? in
            guard let fuelType = selection.fuelType else { return nil }
            let code = fuelType.split(separator: " ").first ?? ""
            return "\(code)(\(selection.percentage)%)"
        }
        return abbreviations.joined(separator: ", ")
    }

    private var hasFuelTypes: Bool {
        // Use the published property to ensure UI updates
        _ = viewModel.fuelTypesChanged
        return !((viewModel.report.fuelTypes as? Set<FuelTypeSelection> ?? []).isEmpty)
    }
    
    private enum ExportType { case kml, csv, pdf }

    private func validateAndExport(type: ExportType) {
        let missing = viewModel.validateReport()
        if missing.isEmpty {
            export(type: type)
        } else {
            self.missingFields = missing
            self.showValidationAlert = true
        }
    }
    
    private func export(type: ExportType) {
        let exporter = DTAReportExporter()
        
        // Report title is automatically maintained by the view model
        let exportTitle = viewModel.reportTitle.isEmpty ? "DTA-Report" : viewModel.reportTitle

        let fileName: String
        let data: Data?
        
        switch type {
        case .kml:
            fileName = "\(exportTitle).kml"
            data = exporter.generateKML(for: viewModel.report).data(using: .utf8)
        case .csv:
            fileName = "\(exportTitle).csv"
            data = exporter.generateCSV(for: viewModel.report).data(using: .utf8)
        case .pdf:
            fileName = "\(exportTitle).pdf"
            data = exporter.generatePDF(for: viewModel.report)
        }
        
        guard let fileData = data else { return }
        
        let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try fileData.write(to: tempUrl)
            self.fileToShare = ShareableFile(url: tempUrl)
        } catch {
            print("Failed to write export file: \(error)")
        }
    }
}
