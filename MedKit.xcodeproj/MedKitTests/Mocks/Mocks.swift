import Testing
import Foundation
@testable import MedKit

struct Mocks {
    class MockMedicineListItemManager: MedicineListItemManagerProtocol {
        var mockedList: [MedicineListItemModel] = []
        var updateStockQuantityCalled = false
        
        func fetchMedicineList(sortOn: MedicineListSortOptionsEnum) throws -> [MedicineListItemModel] {
            return mockedList
        }
        
        func updateStockQuantity(medicineId: UUID, quantity: Float, dosage: DosageModel?) {
            updateStockQuantityCalled = true
        }
    }
    
    class MockMedicineReadManager: MedicineReadManagerProtocol {
        var fetchShoppingListMock: [Medicine] = []
        var fetchByIdMock: Medicine? = nil
        var fetchByIdCalled = false
        
        func fetchShoppingList() throws -> [Medicine] {
            return fetchShoppingListMock
        }
        
        func fetchById(_ id: UUID) throws -> Medicine {
            fetchByIdCalled = true
            if let mock = fetchByIdMock { return mock }
            throw NSError(domain: "MockError", code: 404)
        }
    }
}
