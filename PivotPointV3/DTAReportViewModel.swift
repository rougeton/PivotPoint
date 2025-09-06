import SwiftUI
import CoreData
import PhotosUI

// This is now the single, official definition for an identifiable image.
struct IdentifiableImage: Identifiable {
    let id: UUID
    var image: UIImage
    let mediaAttachment: MediaAttachment
}

final class DTAReportViewModel: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let context: NSManagedObjectContext // This is the child "draft" context
    private let parentContext: NSManagedObjectContext
    
    @Published var report: DTAReport
    
    // UI state properties
    @Published var images: [IdentifiableImage] = []
    @Published var isLoadingPhotos = false
    
    // Properties for direct binding from Views
    @Published var reportTitle: String
    @Published var dtfCompletedBy: String
    @Published var fireNumber: String
    @Published var fireCenter: String
    @Published var assessedBy: String
    @Published var saoOverview: String
    @Published var saoBriefedToCrew: Bool
    @Published var primaryHazardsPresent: Set<String>
    @Published var activity: Set<String>
    // Other properties would be declared here
    
    init(report: DTAReport, parentContext: NSManagedObjectContext, userSettings: UserSettings) {
        self.parentContext = parentContext
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.context.parent = parentContext
        
        // Fetch the report into our private child context for safe editing
        self.report = self.context.object(with: report.objectID) as! DTAReport
        
        // Initialize all @Published properties from the report
        self.reportTitle = self.report.reportTitle ?? ""
        self.dtfCompletedBy = self.report.dtfCompletedBy ?? ""
        self.fireNumber = self.report.fireNumber ?? ""
        self.fireCenter = self.report.fireCenter ?? ""
        self.assessedBy = self.report.assessedBy ?? ""
        self.saoOverview = self.report.saoOverview ?? ""
        self.saoBriefedToCrew = self.report.saoBriefedToCrew
        self.primaryHazardsPresent = Set((self.report.primaryHazardsPresent ?? "").split(separator: ";;").map { String($0) })
        self.activity = Set((self.report.activity ?? "").split(separator: ";;").map { String($0) })
        // ... initialize all other properties
        
        Task { @MainActor in loadExistingPhotos() }
    }
    
    // Called whenever a property changes in the UI
    func saveChanges() {
        // Update the underlying Core Data object from our @Published properties
        report.reportTitle = reportTitle
        report.dtfCompletedBy = dtfCompletedBy
        report.fireNumber = fireNumber
        // ... update all other properties ...
        
        guard context.hasChanges else { return }
        do {
            try context.save()
            if parentContext.hasChanges { try parentContext.save() }
            print("Autosave successful.")
        } catch {
            print("Error autosaving context: \(error)")
        }
    }
    
    // MARK: - Photo & Waypoint Management
    @MainActor
    func addWaypoint(label: String, notes: String?, isSpot: Bool) {
        let waypoint = DTAWaypoint(context: context) // Uses the correct child context
        waypoint.id = UUID()
        waypoint.label = label
        waypoint.locationNotes = notes
        waypoint.isSpotPoint = isSpot
        waypoint.dtaReport = self.report // This relationship is now SAFE
        saveChanges()
    }
    
    @MainActor func loadExistingPhotos() {
        images.removeAll()
        for mediaAttachment in report.mediaAttachmentsArray {
            if let fileURLString = mediaAttachment.fileURL, let url = URL(string: fileURLString), let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
                images.append(IdentifiableImage(id: mediaAttachment.id ?? UUID(), image: loadedImage, mediaAttachment: mediaAttachment))
            }
        }
    }
    
    @MainActor func processPhotos(_ items: [PhotosPickerItem]) {
        isLoadingPhotos = true
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        let mediaAttachment = MediaAttachment(context: self.context)
                        mediaAttachment.id = UUID()
                        mediaAttachment.fileName = "photo_\(Date().timeIntervalSince1970).jpg"
                        mediaAttachment.mediaType = "photo"
                        mediaAttachment.photoTimestamp = Date()
                        mediaAttachment.dtaReport = self.report
                        
                        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            let imageURL = documentsPath.appendingPathComponent(mediaAttachment.fileName ?? "photo.jpg")
                            if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                                try? jpegData.write(to: imageURL)
                                mediaAttachment.fileURL = imageURL.absoluteString
                            }
                        }
                        self.images.append(IdentifiableImage(id: mediaAttachment.id ?? UUID(), image: uiImage, mediaAttachment: mediaAttachment))
                        self.saveChanges()
                    }
                }
            }
            await MainActor.run { isLoadingPhotos = false }
        }
    }
    
    @MainActor func removeImage(_ image: IdentifiableImage) {
        if let fileURL = image.mediaAttachment.fileURL, let url = URL(string: fileURL) { try? FileManager.default.removeItem(at: url) }
        context.delete(image.mediaAttachment)
        images.removeAll { $0.id == image.id }
        saveChanges()
    }
    
    var waypointsArray: [DTAWaypoint] {
        return (report.waypoints as? Set<DTAWaypoint> ?? []).sorted { $0.label ?? "" < $1.label ?? "" }
    }

    // MARK: - Conformance
    static func == (lhs: DTAReportViewModel, rhs: DTAReportViewModel) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
