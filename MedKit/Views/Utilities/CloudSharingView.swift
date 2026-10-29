import CloudKit
import OSLog
import SwiftUI
import UIKit

struct CloudSharingView: UIViewControllerRepresentable {
    let medicine: Medicine
    let share: CKShare
    let container: CKContainer

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        
        controller.delegate = context.coordinator
        controller.availablePermissions = [.allowReadOnly, .allowPrivate, .allowReadWrite]
        
        return controller
    }


    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}

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
                message: AppError.cloudShareFailed.errorDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: String(localized: "OK"), style: .default))
            csc.present(alert, animated: true)
        }

        func itemTitle(for csc: UICloudSharingController) -> String? {
            return parent.medicine.name
        }
    }
}
