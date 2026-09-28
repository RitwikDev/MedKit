import Testing
import Foundation
@testable import MedKit

struct MVMMocks {
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

@Suite
@MainActor
struct MedicineViewModelTests {
    
    @Test
    func fetchAllMedicines_success() {
        let mockListManager = MVMMocks.MockMedicineListItemManager()
        let mockReadManager = MVMMocks.MockMedicineReadManager()
        
        let expectedItem = MedicineListItemModel(
            id: UUID(),
            name: "Paracetamol",
            strengthAmount: 500,
            strengthUnit: "mg",
            stock: nil,
            dosage: nil,
            expiryDate: nil,
            tags: [],
            isOnShoppingList: false,
            isShared: false
        )
        mockListManager.mockedList = [expectedItem]
        
        let viewModel = MedicineViewModel(
            listItemManager: mockListManager,
            readManager: mockReadManager
        )
        
        #expect(viewModel.medicines.count == 1)
        #expect(viewModel.medicines.first?.name == "Paracetamol")
    }
    
    @Test
    func getById_success() {
        let mockListManager = MVMMocks.MockMedicineListItemManager()
        let mockReadManager = MVMMocks.MockMedicineReadManager()
        
        let medicineId = UUID()
        let expectedMedicine = Medicine(
            id: medicineId,
            name: "Aspirin",
            manufacturedDate: nil,
            expiryDate: nil,
            strengthAmount: nil,
            strengthUnit: "",
            composition: [],
            dosage: nil,
            stock: nil,
            isOnShoppingList: false,
            tags: [],
            customFields: [],
            doseLogs: []
        )
        mockReadManager.fetchByIdMock = expectedMedicine
        
        let viewModel = MedicineViewModel(
            listItemManager: mockListManager,
            readManager: mockReadManager
        )
        
        let result = viewModel.getById(medicineId)
        #expect(result?.name == "Aspirin")
        #expect(mockReadManager.fetchByIdCalled == true)
    }
    
    @Test
    func updateStockQuantity() {
        let mockListManager = MVMMocks.MockMedicineListItemManager()
        let mockReadManager = MVMMocks.MockMedicineReadManager()
        
        let viewModel = MedicineViewModel(
            listItemManager: mockListManager,
            readManager: mockReadManager
        )
        
        viewModel.updateStockQuantity(medicineId: UUID(), quantity: 10, dosage: nil)
        
        #expect(mockListManager.updateStockQuantityCalled == true)
    }
}
