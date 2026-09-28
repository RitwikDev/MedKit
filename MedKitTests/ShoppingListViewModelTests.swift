import Testing
import Foundation
import CloudKit
@testable import MedKit

struct SLVMMocks {
    class MockMedicineReadManager: MedicineReadManagerProtocol {
        var fetchShoppingListMock: [Medicine] = []
        var fetchShoppingListCalled = false
        
        func fetchShoppingList() throws -> [Medicine] {
            fetchShoppingListCalled = true
            return fetchShoppingListMock
        }
        
        func fetchById(_ id: UUID) throws -> Medicine {
            throw NSError(domain: "MockError", code: 404)
        }
    }
    
    class MockMedicineWriteManager: MedicineWriteManagerProtocol {
        var savedMedicines: [Medicine] = []
        var saveShouldThrow = false
        
        func save(_ medicine: Medicine) throws {
            if saveShouldThrow {
                throw NSError(domain: "MockError", code: 500)
            }
            savedMedicines.append(medicine)
        }
        
        func delete(_ medicine: Medicine) throws { }
        func deleteMedicine(id: UUID) throws {}
        func deleteAllMedicines() throws {}
        @MainActor func fetchOrCreateShare(for medicine: Medicine) async throws -> (CloudKit.CKShare, CloudKit.CKContainer) {
            throw NSError(domain: "MockError", code: 500)
        }
    }
}

@Suite
struct ShoppingListViewModelTests {
    
    @Test
    func fetchShoppingList_success() {
        let readMock = SLVMMocks.MockMedicineReadManager()
        let writeMock = SLVMMocks.MockMedicineWriteManager()
        
        let expectedItem = Medicine(
            id: UUID(),
            name: "Aspirin",
            manufacturedDate: nil,
            expiryDate: nil,
            strengthAmount: nil,
            strengthUnit: "",
            composition: [],
            dosage: nil,
            stock: nil,
            isOnShoppingList: true,
            tags: [],
            customFields: [],
            doseLogs: []
        )
        readMock.fetchShoppingListMock = [expectedItem]
        
        let viewModel = ShoppingListViewModel(readManager: readMock, writeManager: writeMock)
        viewModel.fetchShoppingList()
        
        #expect(readMock.fetchShoppingListCalled == true)
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name == "Aspirin")
    }
    
    @Test
    func removeFromShoppingList() {
        let readMock = SLVMMocks.MockMedicineReadManager()
        let writeMock = SLVMMocks.MockMedicineWriteManager()
        
        let expectedItem = Medicine(
            id: UUID(),
            name: "Aspirin",
            manufacturedDate: nil,
            expiryDate: nil,
            strengthAmount: nil,
            strengthUnit: "",
            composition: [],
            dosage: nil,
            stock: nil,
            isOnShoppingList: true,
            tags: [],
            customFields: [],
            doseLogs: []
        )
        
        let viewModel = ShoppingListViewModel(readManager: readMock, writeManager: writeMock)
        viewModel.items = [expectedItem]
        
        // Remove the item at index 0
        viewModel.removeFromShoppingList(at: IndexSet(integer: 0))
        
        #expect(writeMock.savedMedicines.count == 1)
        #expect(writeMock.savedMedicines.first?.isOnShoppingList == false)
        #expect(readMock.fetchShoppingListCalled == true)
    }
    
    @Test
    func clearShoppingList() {
        let readMock = SLVMMocks.MockMedicineReadManager()
        let writeMock = SLVMMocks.MockMedicineWriteManager()
        
        let expectedItem1 = Medicine(id: UUID(), name: "First", isOnShoppingList: true, tags: [], customFields: [], doseLogs: [])
        let expectedItem2 = Medicine(id: UUID(), name: "Second", isOnShoppingList: true, tags: [], customFields: [], doseLogs: [])
        
        let viewModel = ShoppingListViewModel(readManager: readMock, writeManager: writeMock)
        viewModel.items = [expectedItem1, expectedItem2]
        
        viewModel.clearShoppingList()
        
        #expect(writeMock.savedMedicines.count == 2)
        #expect(writeMock.savedMedicines[0].isOnShoppingList == false)
        #expect(writeMock.savedMedicines[1].isOnShoppingList == false)
        #expect(readMock.fetchShoppingListCalled == true)
    }
}
