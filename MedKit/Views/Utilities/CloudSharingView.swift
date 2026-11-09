//
//  CloudSharingView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/06/26.
//

import CloudKit
import OSLog
import SwiftUI
import UIKit

struct CloudSharingView: UIViewControllerRepresentable {
    let medicine: Medicine
    var share: CKShare?
    var container: CKContainer?

    func makeUIViewController(context: Context) -> UIViewController {
        if let share = share, let container = container {
            let controller = UICloudSharingController(share: share, container: container)
            controller.delegate = context.coordinator
            controller.availablePermissions = [.allowReadOnly, .allowPrivate, .allowReadWrite]
            return controller
        } else {
            let persistentContainer = PersistenceController.shared.container
            let containerIdentifier = persistentContainer.persistentStoreDescriptions.first?.cloudKitContainerOptions?.containerIdentifier ?? "iCloud.com.rss.MedKit"
            let ckContainer = CKContainer(identifier: containerIdentifier)
            
            let itemProvider = NSItemProvider()
            itemProvider.registerCKShare(container: ckContainer) {
                let (share, _) = try await MedicineWriteManager.shared.fetchOrCreateShare(for: medicine)
                return share
            }
            let configuration = UIActivityItemsConfiguration(itemProviders: [itemProvider])
            return UIActivityViewController(activityItemsConfiguration: configuration)
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        var parent: CloudSharingView
        private let logger = Logger(subsystem: "com.rss.MedKit", category: "CloudSharingView")

        init(_ parent: CloudSharingView) {
            self.parent = parent
        }

        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            logger.error("Failed to save share: \(error.localizedDescription, privacy: .public)")
            let alert = UIAlertController(
                title: String(localized: "Sharing Error"),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
            csc.present(alert, animated: true)
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            return parent.medicine.name
        }
        
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            logger.info("CloudKit share saved successfully.")
        }
        
        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            logger.info("CloudKit share stopped.")
        }
    }
}
