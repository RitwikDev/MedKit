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
    
    /// Initialises the Core Data stack and configures CloudKit sharing zones.
    /// - Parameter inMemory: If true, the database is stored in memory (useful for SwiftUI Previews and Unit Testing).
    private init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MedKit")
        
        guard let defaultDescription = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            defaultDescription.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let storesURL = defaultDescription.url!.deletingLastPathComponent()
            let containerIdentifier = "iCloud.com.rss.MedKit"
            
            // 1. Private Store Configuration
            let privateStoreURL = storesURL.appendingPathComponent("Private.sqlite")
            let privateDescription = NSPersistentStoreDescription(url: privateStoreURL)
            privateDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            privateDescription.cloudKitContainerOptions?.databaseScope = .private
            
            // 2. Shared Store Configuration
            let sharedStoreURL = storesURL.appendingPathComponent("Shared.sqlite")
            let sharedDescription = NSPersistentStoreDescription(url: sharedStoreURL)
            sharedDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
            sharedDescription.cloudKitContainerOptions?.databaseScope = .shared
            
            // Apply both configurations to the container
            container.persistentStoreDescriptions = [privateDescription, sharedDescription]
        }
        
        // Loop through the assigned descriptions and apply the option to ALL of them
        for description in container.persistentStoreDescriptions {
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
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
