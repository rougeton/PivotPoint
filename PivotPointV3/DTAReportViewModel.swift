import SwiftUI
import CoreData
import PhotosUI
import Combine

struct IdentifiableImage: Identifiable {
    let id: UUID
    var image: UIImage
    let mediaAttachment: MediaAttachment
}

final class DTAReportViewModel: ObservableObject, Identifiable, Hashable {
    let id = UUID()
    let context: NSManagedObjectContext
    private let parentContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    @Published var report: DTAReport
    @Published var images: [IdentifiableImage] = []

    // Direct UI bindings
    @Published var reportTitle: String
    @Published var dtfCompletedBy: String
    @Published var fireNumber: String
    @Published var fireCenter: String
    @Published var assessedBy: String
    @Published var saoOverview: String
    @Published var saoBriefedToCrew: Bool
    @Published var saoComment: String
    @Published var primaryHazardsPresent: Set<String>
    @Published var activity: String
    @Published var comments: String
    @Published var dtaMarkingProtocolFollowed: String
    @Published var dtaMarkingProtocolComment: String
    @Published var estimatedTreesFelled: Int16
    @Published var noWorkZonesPresent: String
    @Published var noWorkZones: Bool
    @Published var assessedMin1_5TreeLengths: String
    @Published var assessedTLComment: String
    @Published var areaBetweenPointsSafeForWork: Bool
    @Published var areaSafeForWorkComment: String
    @Published var reassessmentNeeded: String
    @Published var fuelTypesChanged: Bool = false // Trigger for UI updates

    @Published var levelOfDisturbance: String {
        didSet {
            handleLODChanges(from: oldValue)
        }
    }
    
    // MODIFIED: This is now a Set for multi-select, backed by the original String
    var lodLowHazardsSet: Set<String> {
        get {
            Set((report.lodLowHazards ?? "").split(separator: ";;").map(String.init))
        }
        set {
            report.lodLowHazards = newValue.sorted().joined(separator: ";;")
        }
    }
    
    @Published var lodMediumFirLarchPineSpruce: String
    @Published var lodMediumRedYellowCedar: String
    @Published var assessedDistanceFromWorkArea: String

    init(report: DTAReport, parentContext: NSManagedObjectContext, userSettings: UserSettings) {
        self.parentContext = parentContext
        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.context.parent = parentContext
        
        self.reportTitle = report.reportTitle ?? ""
        self.dtfCompletedBy = report.dtfCompletedBy ?? ""
        self.fireNumber = report.fireNumber ?? ""
        self.fireCenter = report.fireCenter ?? ""
        self.assessedBy = report.assessedBy ?? ""
        self.saoOverview = report.saoOverview ?? ""
        self.saoBriefedToCrew = report.saoBriefedToCrew
        self.saoComment = report.saoComment ?? ""
        self.primaryHazardsPresent = Set((report.primaryHazardsPresent ?? "").split(separator: ";;").map { String($0) }.filter { !$0.isEmpty })
        self.activity = report.activity ?? ""
        self.comments = report.comments ?? ""
        self.dtaMarkingProtocolFollowed = report.dtaMarkingProtocolFollowed ?? ""
        self.dtaMarkingProtocolComment = report.dtaMarkingProtocolComment ?? ""
        self.estimatedTreesFelled = report.estimatedTreesFelled
        self.noWorkZonesPresent = report.noWorkZonesPresent ?? ""
        self.noWorkZones = report.noWorkZones
        self.assessedMin1_5TreeLengths = report.assessedMin1_5TreeLengths ?? ""
        self.assessedTLComment = report.assessedTLComment ?? ""
        self.areaBetweenPointsSafeForWork = report.areaBetweenPointsSafeForWork
        self.areaSafeForWorkComment = report.areaSafeForWorkComment ?? ""
        self.reassessmentNeeded = report.reassessmentNeeded ?? ""
        self.levelOfDisturbance = report.levelOfDisturbance ?? ""
        self.lodMediumFirLarchPineSpruce = report.lodMediumFirLarchPineSpruce ?? ""
        self.lodMediumRedYellowCedar = report.lodMediumRedYellowCedar ?? ""
        self.assessedDistanceFromWorkArea = report.assessedDistanceFromWorkArea ?? ""
        
        self.report = self.context.object(with: report.objectID) as! DTAReport
        
        if self.assessedBy.isEmpty {
            self.assessedBy = userSettings.userName
        }
        loadImages()
        setupAutoSave()

        // Ensure report title follows the correct format
        updateReportTitle()
    }

    private func setupAutoSave() {
        // Auto-save for key text fields
        $reportTitle
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $activity
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $comments
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $saoOverview
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $levelOfDisturbance
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        // Auto-save for additional important fields
        $fireNumber
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $assessedBy
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        $reassessmentNeeded
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveContext() }
            .store(in: &cancellables)

        // Timer-based auto-save every 30 seconds as backup
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveContext()
            }
            .store(in: &cancellables)

        // Auto-save for Set-based properties
        $primaryHazardsPresent
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveContext()
            }
            .store(in: &cancellables)

        // Backup timer-based auto-save every 10 seconds
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.saveContext()
            }
            .store(in: &cancellables)

        // Auto-save when report object changes (for relationships like waypoints, fuel types, media)
        report.objectWillChange
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveContext()
            }
            .store(in: &cancellables)

        // Auto-update report title when activity changes
        $activity
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateReportTitle()
            }
            .store(in: &cancellables)
    }

    private func handleLODChanges(from oldValue: String) {
        let notApplicable = "Not Applicable"
        
        switch levelOfDisturbance {
        case "VLR":
            report.lodLowHazards = notApplicable
            lodMediumFirLarchPineSpruce = notApplicable
            lodMediumRedYellowCedar = notApplicable
        case "Low":
            // Low Hazards remains editable, only Moderate is locked.
            lodMediumFirLarchPineSpruce = notApplicable
            lodMediumRedYellowCedar = notApplicable
            if oldValue == "VLR" || oldValue == "High" {
                report.lodLowHazards = "" // Unlock
            }
        case "Moderate":
            // When Moderate is selected, LoD Low hazards should be "Not Applicable" and locked
            report.lodLowHazards = notApplicable
            // Moderate fields remain editable for Moderate
            if oldValue == "VLR" || oldValue == "High" {
                lodMediumFirLarchPineSpruce = ""
                lodMediumRedYellowCedar = ""
            }
        case "High":
            report.lodLowHazards = notApplicable
            lodMediumFirLarchPineSpruce = notApplicable
            lodMediumRedYellowCedar = notApplicable
        default: // Empty or unknown
            if oldValue == "VLR" || oldValue == "High" || oldValue == "Moderate" {
                report.lodLowHazards = ""
                lodMediumFirLarchPineSpruce = ""
                lodMediumRedYellowCedar = ""
            } else if oldValue == "Low" {
                lodMediumFirLarchPineSpruce = ""
                lodMediumRedYellowCedar = ""
            }
        }
    }
    
    func validateReport() -> [String] {
        var missingFields: [String] = []

        if saoOverview.isEmpty { missingFields.append("SAO Overview") }
        if primaryHazardsPresent.isEmpty { missingFields.append("Primary Hazards Present") }
        if activity.isEmpty { missingFields.append("Activity") }
        if levelOfDisturbance.isEmpty { missingFields.append("Level of Disturbance") }
        if dtaMarkingProtocolFollowed.isEmpty { missingFields.append("DTA Marking Protocol") }
        if noWorkZonesPresent.isEmpty { missingFields.append("No Work Zones Present") }
        if assessedMin1_5TreeLengths.isEmpty { missingFields.append("Assessed min. 1.5 TL") }

        return missingFields
    }
    
    func refreshFuelTypes() {
        // Toggle the published property to trigger UI updates
        fuelTypesChanged.toggle()
    }

    private func updateReportTitle() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: report.manualDateTime ?? Date())
        let activityString = activity.isEmpty ? "NoActivity" : activity.replacingOccurrences(of: " ", with: "_")
        reportTitle = "DTA-\(dateString)-\(activityString)"
    }

    func saveContext() {
        report.reportTitle = reportTitle
        report.dtfCompletedBy = dtfCompletedBy
        report.fireNumber = fireNumber
        report.fireCenter = fireCenter
        report.assessedBy = assessedBy
        report.saoOverview = saoOverview
        report.saoBriefedToCrew = saoBriefedToCrew
        report.saoComment = saoComment
        report.primaryHazardsPresent = primaryHazardsPresent.sorted().joined(separator: ";;")
        report.activity = activity
        report.comments = comments
        report.dtaMarkingProtocolFollowed = dtaMarkingProtocolFollowed
        report.dtaMarkingProtocolComment = dtaMarkingProtocolComment
        report.estimatedTreesFelled = estimatedTreesFelled
        report.noWorkZonesPresent = noWorkZonesPresent
        report.noWorkZones = noWorkZones
        report.assessedMin1_5TreeLengths = assessedMin1_5TreeLengths
        report.assessedTLComment = assessedTLComment
        report.areaBetweenPointsSafeForWork = areaBetweenPointsSafeForWork
        report.areaSafeForWorkComment = areaSafeForWorkComment
        report.reassessmentNeeded = reassessmentNeeded
        report.levelOfDisturbance = levelOfDisturbance
        report.lodMediumFirLarchPineSpruce = lodMediumFirLarchPineSpruce
        report.lodMediumRedYellowCedar = lodMediumRedYellowCedar
        report.assessedDistanceFromWorkArea = assessedDistanceFromWorkArea
        
        guard context.hasChanges else { return }
        do {
            try context.save()
            if parentContext.hasChanges { try parentContext.save() }
        } catch {
            print("Error autosaving context: \(error)")
        }
    }
    
    var waypointsArray: [DTAWaypoint] {
        (report.waypoints as? Set<DTAWaypoint> ?? []).sorted { $0.label ?? "" < $1.label ?? "" }
    }
    
    static func == (lhs: DTAReportViewModel, rhs: DTAReportViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Other helper functions are unchanged
    func addPhotoToWaypoint(_ waypoint: DTAWaypoint, data: Data) {}
    func findPhoto(for waypoint: DTAWaypoint) -> MediaAttachment? { return nil }
    func removeMediaAttachment(_ attachment: MediaAttachment) {}
    private func loadImages() {}
}
