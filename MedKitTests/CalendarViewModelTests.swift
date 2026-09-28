import Testing
import Foundation
import CloudKit
import SwiftUI
@testable import MedKit

struct CVMMocks {
    class MockGlobalDataManager: GlobalDataManagerProtocol {
        var recordName = "TestUser"
        func fetchCurrentRecordName() async -> String? { return recordName }
        func fetchAllTags() throws -> [MedKit.Tag] { return [] }
        func fetchAllIngredients() throws -> [Ingredient] { return [] }
        func fetchAllCustomFields() throws -> [CustomField] { return [] }
        func fetchAllStrengthUnits() throws -> Set<String> { return [] }
        func fetchAllStockTypes() throws -> Set<String> { return [] }
        func deleteTag(id: UUID) throws {}
        func deleteIngredient(id: UUID) throws {}
        func deleteCustomField(id: UUID) throws {}
        func deleteAllMedicines() throws {}
        func deleteAllTags() throws {}
        func deleteAllIngredients() throws {}
        func deleteAllCustomFields() throws {}
    }
    
    class MockCalendarMedicineReadManager: CalendarMedicineReadManagerProtocol {
        var mockMedicines: [CalendarMedicine] = []
        func getMedicines() throws -> [CalendarMedicine] { return mockMedicines }
    }
    
    actor MockScheduleGenerationService: ScheduleGenerationServiceProtocol {
        var mockEvents: [Date: [CalendarEvent]] = [:]
        func generateEvents(for targetMonth: Date, medicines: [CalendarMedicine], currentRecordName: String) async -> [Date: [CalendarEvent]] {
            return mockEvents
        }
    }
    
    class MockMedicineReadManager: MedicineReadManagerProtocol {
        var mockMedicine: Medicine!
        func fetchById(_ id: UUID) throws -> Medicine {
            if let med = mockMedicine { return med }
            throw NSError(domain: "", code: 404)
        }
        func fetchShoppingList() throws -> [Medicine] { return [] }
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
struct CalendarViewModelTests {
    
    @Test
    func changeMonth_success() {
        let viewModel = CalendarViewModel(
            globalDataManager: CVMMocks.MockGlobalDataManager(),
            calendarMedicineReadManager: CVMMocks.MockCalendarMedicineReadManager(),
            medicineReadManager: CVMMocks.MockMedicineReadManager(),
            medicineWriteManager: CVMMocks.MockMedicineWriteManager(),
            scheduleService: CVMMocks.MockScheduleGenerationService()
        )
        
        let initialMonth = viewModel.currentMonth
        viewModel.changeMonth(by: 1)
        #expect(viewModel.currentMonth > initialMonth)
    }
    
    @Test
    func initialiseMedicines_fetchesData() async {
        let globalMock = CVMMocks.MockGlobalDataManager()
        let readMock = CVMMocks.MockCalendarMedicineReadManager()
        readMock.mockMedicines = []
        
        let viewModel = CalendarViewModel(
            globalDataManager: globalMock,
            calendarMedicineReadManager: readMock,
            medicineReadManager: CVMMocks.MockMedicineReadManager(),
            medicineWriteManager: CVMMocks.MockMedicineWriteManager(),
            scheduleService: CVMMocks.MockScheduleGenerationService()
        )
        
        viewModel.initialiseMedicines()
        
        // Wait for async fetch to finish in Task
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(viewModel.currentRecordName == "TestUser")
    }
    
    @Test
    func toggleDoseLog_addsLog() async {
        let readMock = CVMMocks.MockMedicineReadManager()
        let writeMock = CVMMocks.MockMedicineWriteManager()
        
        let medId = UUID()
        readMock.mockMedicine = Medicine(id: medId, name: "Test Med", tags: [], customFields: [], doseLogs: [])
        
        let viewModel = CalendarViewModel(
            globalDataManager: CVMMocks.MockGlobalDataManager(),
            calendarMedicineReadManager: CVMMocks.MockCalendarMedicineReadManager(),
            medicineReadManager: readMock,
            medicineWriteManager: writeMock,
            scheduleService: CVMMocks.MockScheduleGenerationService()
        )
        
        let event = CalendarEvent(date: Date(), title: "Take", color: .blue, medicineID: medId, isTaken: false, eventType: .dosage)
        
        viewModel.toggleDoseLog(for: event)
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        #expect(writeMock.savedMedicine != nil)
        #expect(writeMock.savedMedicine?.doseLogs.count == 1)
        #expect(writeMock.savedMedicine?.doseLogs.first?.isTaken == true)
    }
}
