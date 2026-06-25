import Foundation
import CoreData

/// A modular manager responsible for initializing and managing the Core Data stack
/// and its integration with CloudKit for both private and shared databases.
public final class PersistenceController {
    
    /// The shared singleton instance of the persistence controller.
    public static let shared = PersistenceController()
    
    /// The underlying CloudKit container managing the Core Data SQLite stores.
    public let container: NSPersistentCloudKitContainer
    
    /// Initializes the Core Data stack and configures CloudKit sharing zones.
    /// - Parameter inMemory: If true, the database is stored in memory (useful for SwiftUI Previews and Unit Testing).
    private init(inMemory: Bool = false) {
        // Must match the exact name of your .xcdatamodeld file
        container = NSPersistentCloudKitContainer(name: "MedKit")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storesURL = description.url!.deletingLastPathComponent()
            let containerIdentifier = "iCloud.com.rss.MedKit"
            
            // 1. Private Store Configuration
            let privateStoreURL = storesURL.appendingPathComponent("Private.sqlite")
            let privateDescription = NSPersistentStoreDescription(url: privateStoreURL)
            privateDescription.configuration = "Private"
            privateDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateDescription.cloudKitContainerOptions?.databaseScope = .private
            
            // 2. Shared Store Configuration
            let sharedStoreURL = storesURL.appendingPathComponent("Shared.sqlite")
            let sharedDescription = NSPersistentStoreDescription(url: sharedStoreURL)
            sharedDescription.configuration = "Shared"
            sharedDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            sharedDescription.cloudKitContainerOptions?.databaseScope = .shared
            
            // Apply both configurations to the container
            container.persistentStoreDescriptions = [privateDescription, sharedDescription]
        }
        
        // Load the persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, log to a telemetry service or display a critical error alert.
                fatalError("Unresolved error loading Core Data stores: \(error), \(error.userInfo)")
            }
        }
        
        // Ensure the context automatically merges changes synced remotely from iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}