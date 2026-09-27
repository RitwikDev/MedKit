import Testing
import Foundation
@testable import MedKit

@Suite
struct MedicineStockQuantityUpdaterTests {
    
    @Test
    func updateIncrementWithoutDosage() {
        let result = MedicineStockQuantityUpdater.update(isIncrement: true, quantity: 10, dosage: nil)
        #expect(result == 11.0)
    }
    
    @Test
    func updateDecrementWithoutDosage() {
        let result = MedicineStockQuantityUpdater.update(isIncrement: false, quantity: 10, dosage: nil)
        #expect(result == 9.0)
    }
    
    @Test
    func updateDecrementBelowZero() {
        let result = MedicineStockQuantityUpdater.update(isIncrement: false, quantity: 0, dosage: nil)
        #expect(result == 0.0)
    }
    
    @Test
    func updateIncrementWithDosage() {
        let dosage = DosageModel(id: UUID(), dosageQuantity: 2.5, repeatType: .daily)
        let result = MedicineStockQuantityUpdater.update(isIncrement: true, quantity: 10, dosage: dosage)
        #expect(result == 12.5)
    }
    
    @Test
    func updateDecrementWithDosage() {
        let dosage = DosageModel(id: UUID(), dosageQuantity: 2.5, repeatType: .daily)
        let result = MedicineStockQuantityUpdater.update(isIncrement: false, quantity: 10, dosage: dosage)
        #expect(result == 7.5)
    }
}
