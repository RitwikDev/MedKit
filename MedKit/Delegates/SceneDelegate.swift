//
//  SceneDelegate.swift
//  MedKit
//
//  Created by Rishik Dev on 24/06/26.
//

import CloudKit
import SwiftUI

// 1. The Scene Delegate (This catches the event in SwiftUI apps)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let container = PersistenceController.shared.container
        guard let sharedStore = container.persistentStoreCoordinator.persistentStores.first(where: { $0.url?.lastPathComponent == "Shared.sqlite" }) else {
            print("Accept Share Error: Could not locate the Shared database store.")
            return
        }
        
        // Accept the share
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { _, error in
            if let error = error {
                print("Accept Share Error: \(error.localizedDescription)")
            } else {
                print("Successfully accepted the CloudKit share! Data is syncing...")
            }
        }
    }
}
