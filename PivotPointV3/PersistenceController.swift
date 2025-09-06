import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let newFolder = FireFolder(context: viewContext)
        newFolder.id = UUID()
        newFolder.fireNumber = "2025-001"
        newFolder.folderName = "Preview Fire"
        newFolder.erpDocumentPath = "/erp/docs/2025-001"
        newFolder.iapDocumentPath = "/iap/docs/2025-001"

        let report1 = DTAReport(context: viewContext)
        report1.id = UUID()
        report1.reportTitle = "Preview Report Alpha"
        report1.assessedBy = "Preview User"
        report1.manualDateTime = Date()
        report1.fireNumber = "2025-001"
        report1.fireFolder = newFolder

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Pivot_PointV2")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Step to reset the store: Delete the existing SQLite file if it exists
            let storeDescription = container.persistentStoreDescriptions.first
            if let url = storeDescription?.url {
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: url.path) {
                    do {
                        try fileManager.removeItem(at: url)
                        print("Successfully deleted old persistent store at \(url.path)")
                    } catch {
                        print("Failed to delete old persistent store: \(error.localizedDescription)")
                    }
                }
            }
        }

        // Keep lightweight migration enabled for future changes
        container.persistentStoreDescriptions.forEach { description in
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Migration error: \(error), \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
