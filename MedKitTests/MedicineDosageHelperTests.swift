import Testing
import Foundation
@testable import MedKit

@Suite
struct MedicineDosageHelperTests {
    
    @Test
    func getNextDosageDate_neverRepeat_beforeStart() {
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: tomorrow, endDate: nil, reminderTimes: [], repeatType: .never, selectedDays: [], selectedDates: [])
        
        // If we ask for the next dosage starting from today, it should be tomorrow
        let nextDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: today)
        #expect(calendar.isDate(nextDate!, inSameDayAs: tomorrow))
    }
    
    @Test
    func getNextDosageDate_neverRepeat_afterStart() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: yesterday, endDate: nil, reminderTimes: [], repeatType: .never, selectedDays: [])
        
        let nextDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: today)
        #expect(nextDate == nil)
    }

    @Test
    func getNextDosageDate_selectDays() {
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        // Use a date we know the weekday of, but let's just use current components
        let weekday = calendar.component(.weekday, from: today)
        let dayEnum = Day(weekdayNumber: weekday)!
        
        // Set up dosage matching today's weekday
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: today, endDate: nextWeek, reminderTimes: [], repeatType: .selectDays, selectedDays: [dayEnum], selectedDates: [])
        
        let nextDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: today)
        #expect(calendar.isDate(nextDate!, inSameDayAs: today))
    }
    
    @Test
    func getNextDosageDate_withEndDatePassed() {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        
        // Fortnightly schedule that already ended
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: lastWeek, endDate: yesterday, reminderTimes: [], repeatType: .fortnightly, selectedDays: [], selectedDates: [])
        
        let nextDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: today)
        #expect(nextDate == nil)
    }
}
