import Testing
import Foundation
@testable import MedKit

@Suite
struct MedicineStockEndDateCalculatorTests {
    
    @Test
    func calculateTest_missingStock_returnsNil() {
        let result = MedicineStockEndDateCalculator.calculate(stock: nil, dosage: nil)
        #expect(result == nil)
    }

    @Test
    func calculateTest_sufficientStockForNeverRepeat_returnsNil() {
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: Date(), reminderTimes: [ReminderTime(time: Date())], repeatType: .never)
        let stock = StockModel(quantity: 1.0, unit: "Pill")
        
        let result = MedicineStockEndDateCalculator.calculate(stock: stock, dosage: dosage)
        // Never repeating and sufficient stock means it doesn't end (nil)
        #expect(result == nil)
    }

    @Test
    func calculateTest_insufficientStockForNeverRepeat_returnsStartDate() {
        let today = Calendar.current.startOfDay(for: Date())
        let dosage = DosageModel(id: UUID(), dosageQuantity: 2.0, startDate: today, reminderTimes: [ReminderTime(time: Date())], repeatType: .never)
        let stock = StockModel(quantity: 1.0, unit: "Pill")
        
        let result = MedicineStockEndDateCalculator.calculate(stock: stock, dosage: dosage)
        // Needs 2 but has 1, stocks out on the initial dose day
        #expect(result == today)
    }
    
    @Test
    func calculateTest_fortnightly_exhaustsProperly() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: today, reminderTimes: [ReminderTime(time: Date())], repeatType: .fortnightly)
        // Has 2.5 pills, uses 1 every 14 days
        let stock = StockModel(quantity: 2.5, unit: "Pill")
        
        let result = MedicineStockEndDateCalculator.calculate(stock: stock, dosage: dosage)
        let expectedDate = calendar.date(byAdding: .day, value: 14, to: today)
        #expect(result == expectedDate)
    }
}
