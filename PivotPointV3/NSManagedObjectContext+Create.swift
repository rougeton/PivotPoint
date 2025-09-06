import CoreData

extension NSManagedObjectContext {
    
    /// Creates a new Core Data object of the given type and automatically assigns a UUID to its `id` property if it exists.
    func create<T: NSManagedObject>(_ type: T.Type) -> T {
        let entityName = String(describing: type)
        
        guard let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as? T else {
            fatalError("Failed to create \(entityName)")
        }
        
        // Automatically set UUID if the entity has an 'id' attribute
        if object.entity.attributesByName.keys.contains("id") {
            object.setValue(UUID(), forKey: "id")
        }
        
        return object
    }
}
