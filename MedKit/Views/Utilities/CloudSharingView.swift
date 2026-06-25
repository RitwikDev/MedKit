import SwiftUI
import CloudKit

/// A SwiftUI wrapper for Apple's native CloudKit sharing screen.
struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        
        // Set permissions: allow others to read/write, or read-only
        controller.availablePermissions = [.allowPublic, .allowPrivate, .allowReadWrite, .allowReadOnly]
        
        // Optional: Provide an image/icon for the top of the share sheet
        // controller.delegate = context.coordinator 
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        // No updates needed
    }
}