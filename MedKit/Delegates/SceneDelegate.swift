//
//  SceneDelegate.swift
//  MedKit
//
//  Created by Rishik Dev on 24/06/26.
//

import CloudKit
import OSLog
import SwiftUI

// 1. The Scene Delegate (This catches the event in SwiftUI apps)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let logger = Logger(subsystem: "com.rss.MedKit", category: "SceneDelegate")
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shareMetadata = connectionOptions.cloudKitShareMetadata,
           let windowScene = scene as? UIWindowScene {
            self.windowScene(windowScene, userDidAcceptCloudKitShareWith: shareMetadata)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let container = PersistenceController.shared.container
        guard let sharedStore = PersistenceController.shared.sharedStore else {
            logger.error("Accept Share Error: Could not locate the Shared database store.")
            NotificationCenter.default.post(
                name: NotificationManager.shareProcessingFailed,
                object: AppError.shareAcceptFailed.errorDescription
            )
            return
        }
        
        // Notify UI to show processing spinner
        NotificationCenter.default.post(name: NotificationManager.shareProcessingStarted, object: nil)
        
        // Accept the share
        container.acceptShareInvitations(from: [cloudKitShareMetadata], into: sharedStore) { [weak self] _, error in
            if let error = error {
                self?.logger.error("Accept Share Error: \(error.localizedDescription, privacy: .public)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NotificationManager.shareProcessingFailed,
                        object: error.localizedDescription
                    )
                }
            } else {
                self?.logger.info("Successfully accepted the CloudKit share! Data is syncing...")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NotificationManager.shareProcessingFinished, object: nil)
                }
            }
        }
    }
}
