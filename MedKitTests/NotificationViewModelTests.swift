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
        
        var shouldThrowOnSchedule = false
        
        func requestAuthorisation() { requestedAuth = true }
        func registerCategories() { registeredCategories = true }
        
        func scheduleInitialNotification(for medicine: Medicine) throws {
            if shouldThrowOnSchedule {
                throw NSError(domain: "NotificationError", code: -1)
            }
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
        
        var rescheduledPendingIrregular = false
        func reschedulePendingIrregularNotificationsIfNeeded() async {
            rescheduledPendingIrregular = true
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
    
    @Test
    func reschedulePendingIrregular_success() async {
        let mockManager = NVMMocks.MockNotificationManager()
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        viewModel.reschedulePendingIrregularNotificationsIfNeeded()
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(mockManager.rescheduledPendingIrregular == true)
    }
    
    @Test
    func scheduleInitialNotification_errorSetsUserFriendlyMessage() {
        let mockManager = NVMMocks.MockNotificationManager()
        mockManager.shouldThrowOnSchedule = true
        let viewModel = NotificationViewModel(notificationManager: mockManager)
        
        let med = Medicine(id: UUID(), name: "TestMed", tags: [], customFields: [], doseLogs: [])
        viewModel.scheduleInitialNotification(for: med)
        #expect(viewModel.errorMessage == AppError.notificationScheduleFailed.errorDescription)
    }
}
