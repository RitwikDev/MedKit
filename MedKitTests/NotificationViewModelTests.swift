import Testing
import Foundation
import UserNotifications
@testable import MedKit

struct NVMMocks {
    class MockNotificationManager: NotificationManagerProtocol {
        var requestedAuth = false
        var registeredCategories = false
        var scheduledInitialId: UUID? = nil
        var pendingMockRequests: [UNNotificationRequest] = []
        var removedIds: [String] = []
        var removedAll = false
        var removedByMedicineId: UUID? = nil
        
        func requestAuthorisation() { requestedAuth = true }
        func registerCategories() { registeredCategories = true }
        
        func scheduleInitialNotification(for medicine: Medicine) throws {
            scheduledInitialId = medicine.id
        }
        
        func getPendingNotificationRequests() async -> [UNNotificationRequest] {
            return pendingMockRequests
        }
        
        func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
            removedIds.append(contentsOf: identifiers)
        }
        
        func removePendingNotificationRequests(for medicineId: UUID) async {
            removedByMedicineId = medicineId
        }
        
        func removeAllPendingNotificationRequests() {
            removedAll = true
        }
    }
}

@Suite
@MainActor
struct NotificationViewModelTests {
    
    @Test
    func requestAuthorisation_success() {
        let mockManager = NVMMocks.MockNotificationManager()
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        viewModel.requestAuthorisation()
        #expect(mockManager.requestedAuth == true)
    }
    
    @Test
    func registerCategories_success() {
        let mockManager = NVMMocks.MockNotificationManager()
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        viewModel.registerCategories()
        #expect(mockManager.registeredCategories == true)
    }
    
    @Test
    func scheduleInitialNotification_success() {
        let mockManager = NVMMocks.MockNotificationManager()
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        let med = Medicine(id: UUID(), name: "TestMed", tags: [], customFields: [], doseLogs: [])
        viewModel.scheduleInitialNotification(for: med)
        #expect(mockManager.scheduledInitialId == med.id)
    }
    
    @Test
    func removeAll_success() {
        let mockManager = NVMMocks.MockNotificationManager()
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        viewModel.removeAllPendingNotificationRequests()
        #expect(mockManager.removedAll == true)
    }
}
