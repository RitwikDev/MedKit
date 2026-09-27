import Testing
import Foundation
@testable import MedKit

@Suite
@MainActor
struct MedicineViewModelTests {
    
    @Test
    func fetchAllMedicines_success() {
        let mockListManager = Mocks.MockMedicineListItemManager()
        let mockReadManager = Mocks.MockMedicineReadManager()
        
        let expectedItem = MedicineListItemModel(
            id: UUID(),
            name: "Paracetamol",
            strengthAmount: 500,
            strengthUnit: "mg",
            stock: nil,
            dosage: nil,
            expiryDate: nil,
            tags: []
        )
        mockListManager.mockedList = [expectedItem]
        
        let viewModel = MedicineViewModel(
            listItemManager: mockListManager,
            readManager: mockReadManager
        )
        
        // Wait since init triggers it asynchronously or synchronously? The init calls fetchAllMedicines() synchronously.
        #expect(viewModel.medicines.count == 1)
        #expect(viewModel.medicines.first?.name == "Paracetamol")
    }
    
    @Test
    func getById_success() {
        let mockListManager = Mocks.MockMedicineListItemManager()
        let mockReadManager = Mocks.MockMedicineReadManager()
        
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
        let mockListManager = Mocks.MockMedicineListItemManager()
        let mockReadManager = Mocks.MockMedicineReadManager()
        
        let viewModel = MedicineViewModel(
            listItemManager: mockListManager,
            readManager: mockReadManager
        )
        
        viewModel.updateStockQuantity(medicineId: UUID(), quantity: 10, dosage: nil)
        
        #expect(mockListManager.updateStockQuantityCalled == true)
    }
}
