import SwiftUI
import Testing
import Foundation
@testable import MedKit

struct GDVMMocks {
    class MockGlobalDataManager: GlobalDataManagerProtocol {
        var mockTags: [MedKit.Tag] = []
        var mockIngredients: [Ingredient] = []
        var mockCustomFields: [CustomField] = []
        var mockStrengthUnits: Set<String> = []
        var mockStockTypes: Set<String> = []
        
        var deleteTagCalled = false
        var deleteAllTagsCalled = false
        
        func fetchAllTags() throws -> [MedKit.Tag] { return mockTags }
        func fetchAllIngredients() throws -> [Ingredient] { return mockIngredients }
        func fetchAllCustomFields() throws -> [CustomField] { return mockCustomFields }
        func fetchAllStrengthUnits() throws -> Set<String> { return mockStrengthUnits }
        func fetchAllStockTypes() throws -> Set<String> { return mockStockTypes }
        
        func deleteTag(id: UUID) throws { deleteTagCalled = true }
        func deleteIngredient(id: UUID) throws { }
        func deleteCustomField(id: UUID) throws { }
        func deleteAllMedicines() throws { }
        func deleteAllTags() throws { deleteAllTagsCalled = true }
        func deleteAllIngredients() throws { }
        func deleteAllCustomFields() throws { }
        func fetchCurrentRecordName() async -> String? { return "TestUser" }
    }
}

@Suite
@MainActor
struct GlobalDataViewModelTests {
    
    @Test
    func initialization_fetchesAllData() {
        let mockManager = GDVMMocks.MockGlobalDataManager()
        
        let expectedTag = MedKit.Tag(id: UUID(), value: "Headache",)
        mockManager.mockTags = [expectedTag]
        
        let viewModel = GlobalDataViewModel(manager: mockManager)
        
        #expect(viewModel.allTags.count == 1)
        #expect(viewModel.allTags.first?.value == "Headache")
    }
    
    @Test
    func deleteTag_success() {
        let mockManager = GDVMMocks.MockGlobalDataManager()
        let expectedTag = MedKit.Tag(id: UUID(), value: "Cold")
        mockManager.mockTags = [expectedTag]
        
        let viewModel = GlobalDataViewModel(manager: mockManager)
        viewModel.deleteTag(at: IndexSet(integer: 0))
        
        #expect(mockManager.deleteTagCalled == true)
    }
    
    @Test
    func deleteAllTags_success() {
        let mockManager = GDVMMocks.MockGlobalDataManager()
        let viewModel = GlobalDataViewModel(manager: mockManager)
        
        viewModel.deleteAllTags()
        #expect(mockManager.deleteAllTagsCalled == true)
    }
}
