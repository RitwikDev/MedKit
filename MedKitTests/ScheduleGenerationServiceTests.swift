import Testing
import Foundation
import SwiftUI
@testable import MedKit

@Suite
struct ScheduleGenerationServiceTests {
    
    @Test
    func generateEvents_expiryDate() async {
        let calendar = Calendar.current
        let today = Date()
        let thisMonth = calendar.startOfDay(for: today)
        
        let med = CalendarMedicine(id: UUID(), name: "Aspirin", expiryDate: today, dosage: nil, stock: nil, doseLogs: [])
        
        let service = ScheduleGenerationService()
        let expectedEvents = await service.generateEvents(for: thisMonth, medicines: [med], currentRecordName: "You")
        
        // Should produce 1 expiry event today
        let dateKey = calendar.startOfDay(for: today)
        let eventsToday = expectedEvents[dateKey] ?? []
        #expect(eventsToday.count == 1)
        #expect(eventsToday.first?.eventType == .expiry)
    }

    @Test
    func generateEvents_dosageEvents() async {
        let calendar = Calendar.current
        let today = Date()
        let thisMonth = calendar.startOfDay(for: today)
        
        // Setup reminder time at 8:00 AM
        var reminderComponents = calendar.dateComponents([.year, .month, .day], from: today)
        reminderComponents.hour = 8
        reminderComponents.minute = 0
        let reminderTime = calendar.date(from: reminderComponents)!
        
        let dosage = DosageModel(id: UUID(), dosageQuantity: 1.0, startDate: today, reminderTimes: [ReminderTime(time: reminderTime)], repeatType: .never)
        
        let med = CalendarMedicine(id: UUID(), name: "Tylenol", expiryDate: nil, dosage: dosage, stock: nil, doseLogs: [])
        
        let service = ScheduleGenerationService()
        let expectedEvents = await service.generateEvents(for: thisMonth, medicines: [med], currentRecordName: "You")
        
        let dateKey = calendar.startOfDay(for: today)
        let eventsToday = expectedEvents[dateKey] ?? []
        #expect(eventsToday.count == 1)
        #expect(eventsToday.first?.eventType == .dosage)
    }
}
