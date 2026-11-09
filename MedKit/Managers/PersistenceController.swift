//
//  PersistenceController.swift
//  MedKit
//
//  Created by Rishik Dev on 19/06/26.
//

import CloudKit
import CoreData
import Foundation

/// A modular manager responsible for initialising and managing the Core Data stack
/// and its integration with CloudKit for both private and shared databases.
public final class PersistenceController {
    
    /// The shared singleton instance of the persistence controller.
    public static let shared = PersistenceController()
    
    /// The underlying CloudKit container managing the Core Data SQLite stores.
    public let container: NSPersistentCloudKitContainer
    
    /// The shared persistent store where accepted CloudKit shares are stored.
    public private(set) var sharedPersistentStore: NSPersistentStore?
    
    /// The private persistent store where the user's private data is stored.
    public private(set) var privatePersistentStore: NSPersistentStore?
    
    /// Helper property to safely retrieve the shared persistent store.
    public var sharedStore: NSPersistentStore? {
        if let store = sharedPersistentStore {
            return store
        }
        return container.persistentStoreCoordinator.persistentStores.first { store in
            store.url?.lastPathComponent.caseInsensitiveCompare("Shared.sqlite") == .orderedSame
        }
    }
    
    /// Initialises the Core Data stack and configures CloudKit sharing zones.
    /// - Parameter inMemory: If true, the database is stored in memory (useful for SwiftUI Previews and Unit Testing).
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MedKit")
        
        guard let defaultDescription = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            defaultDescription.url = URL(fileURLWithPath: "/dev/null")
            defaultDescription.type = NSInMemoryStoreType
            defaultDescription.cloudKitContainerOptions = nil
            container.persistentStoreDescriptions = [defaultDescription]
        } else {
            let storesURL = defaultDescription.url!.deletingLastPathComponent()
            let containerIdentifier = "iCloud.com.rss.MedKit"
            
            // 1. Private Store Configuration
            let privateStoreURL = storesURL.appendingPathComponent("Private.sqlite")
            defaultDescription.url = privateStoreURL
            defaultDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            defaultDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            let privateOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateOptions.databaseScope = .private
            defaultDescription.cloudKitContainerOptions = privateOptions
            
            // 2. Shared Store Configuration
            guard let sharedDescription = defaultDescription.copy() as? NSPersistentStoreDescription else {
                fatalError("Copying the private store description returned an unexpected value.")
            }
            let sharedStoreURL = storesURL.appendingPathComponent("Shared.sqlite")
            sharedDescription.url = sharedStoreURL
            let sharedOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            sharedOptions.databaseScope = .shared
            sharedDescription.cloudKitContainerOptions = sharedOptions
            
            // Apply both configurations to the container
            container.persistentStoreDescriptions = [defaultDescription, sharedDescription]
        }
        
        // Load the persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, log to a telemetry service or display a critical error alert.
                fatalError("Unresolved error loading Core Data stores: \(error), \(error.userInfo)")
            }
        }
        
        if !inMemory {
            let storesURL = defaultDescription.url!.deletingLastPathComponent()
            let privateStoreURL = storesURL.appendingPathComponent("Private.sqlite")
            let sharedStoreURL = storesURL.appendingPathComponent("Shared.sqlite")
            
            let coordinator = container.persistentStoreCoordinator
            self.privatePersistentStore = coordinator.persistentStore(for: privateStoreURL)
            self.sharedPersistentStore = coordinator.persistentStore(for: sharedStoreURL)
        }
        
        // Ensure the context automatically merges changes synced remotely from iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
#if DEBUG
    /// Creates a fresh instance specifically for testing with an in-memory context.
    /// Do not use in production code; use `.shared` instead.
    public static func createForTesting(inMemory: Bool = true) -> PersistenceController {
        return PersistenceController(inMemory: inMemory)
    }
#endif
}
