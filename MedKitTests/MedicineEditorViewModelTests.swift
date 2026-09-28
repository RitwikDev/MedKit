import SwiftUI
import Testing
import Foundation
import CloudKit
import UserNotifications
@testable import MedKit

struct MEVMMocks {
    class MockNotificationManager: NotificationManagerProtocol {
        func requestAuthorisation() {}
        func registerCategories() {}
        func scheduleInitialNotification(for medicine: Medicine) throws {}
        func getPendingNotificationRequests() async -> [UserNotifications.UNNotificationRequest] { return [] }
        func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {}
        func removePendingNotificationRequests(for medicineId: UUID) async {}
        func removeAllPendingNotificationRequests() {}
    }
    
    class MockMedicineWriteManager: MedicineWriteManagerProtocol {
        var savedMedicine: Medicine?
        func save(_ medicine: Medicine) throws { savedMedicine = medicine }
        func deleteMedicine(id: UUID) throws {}
        func deleteAllMedicines() throws {}
        @MainActor func fetchOrCreateShare(for medicine: Medicine) async throws -> (CloudKit.CKShare, CloudKit.CKContainer) {
            throw NSError(domain: "", code: 500)
        }
    }
}

@Suite
@MainActor
struct MedicineEditorViewModelTests {
    
    @Test
    func insertIngredient_success() {
        let viewModel = MedicineEditorViewModel(
            notificationManager: MEVMMocks.MockNotificationManager(),
            writeManager: MEVMMocks.MockMedicineWriteManager()
        )
        let ingredient = Ingredient(id: UUID(), name: "Water")
        
        viewModel.upsertIngredient(ingredient)
        #expect(viewModel.medicine.composition.count == 1)
        #expect(viewModel.medicine.composition.first?.name == "Water")
    }
    
    @Test
    func saveMedicine_emptyNameThrows() {
        let writeMock = MEVMMocks.MockMedicineWriteManager()
        let viewModel = MedicineEditorViewModel(
            notificationManager: MEVMMocks.MockNotificationManager(),
            writeManager: writeMock
        )
        viewModel.medicine.name = "" // empty name
        
        #expect(throws: ValidationError.self) {
            try viewModel.saveMedicine()
        }
    }
    
    @Test
    func saveMedicine_success() throws {
        let writeMock = MEVMMocks.MockMedicineWriteManager()
        let viewModel = MedicineEditorViewModel(
            notificationManager: MEVMMocks.MockNotificationManager(),
            writeManager: writeMock
        )
        viewModel.medicine.name = "ValidMedicine"
        viewModel.medicine.strengthAmount = 100
        viewModel.medicine.strengthUnit = "mg"
        
        try viewModel.saveMedicine()
        
        #expect(writeMock.savedMedicine != nil)
        #expect(writeMock.savedMedicine?.name == "ValidMedicine")
    }
    
    @Test
    func removeTag() {
        let viewModel = MedicineEditorViewModel(
            notificationManager: MEVMMocks.MockNotificationManager(),
            writeManager: MEVMMocks.MockMedicineWriteManager()
        )
        let tag = MedKit.Tag(id: UUID(), value: "Pain")
        viewModel.addTag(tag)
        #expect(viewModel.medicine.tags.count == 1)
        
        viewModel.removeTag(at: IndexSet(integer: 0))
        #expect(viewModel.medicine.tags.isEmpty)
    }
}
