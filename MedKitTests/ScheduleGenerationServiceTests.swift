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

    @Test
    func generateEvents_alternateDaysDosage() async {
        let calendar = Calendar.current
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let day0 = firstOfMonth
        let day1 = calendar.date(byAdding: .day, value: 1, to: day0)!
        let day2 = calendar.date(byAdding: .day, value: 2, to: day0)!
        let day3 = calendar.date(byAdding: .day, value: 3, to: day0)!
        let day4 = calendar.date(byAdding: .day, value: 4, to: day0)!
        let day5 = calendar.date(byAdding: .day, value: 5, to: day0)!
        
        let reminderTime = ReminderTime(time: day0)
        let dosage = DosageModel(
            id: UUID(),
            dosageQuantity: 1.0,
            startDate: day0,
            endDate: day4,
            reminderTimes: [reminderTime],
            repeatType: .alternateDays
        )
        
        let med = CalendarMedicine(id: UUID(), name: "Advil", expiryDate: nil, dosage: dosage, stock: nil, doseLogs: [])
        
        let service = ScheduleGenerationService()
        let expectedEvents = await service.generateEvents(for: firstOfMonth, medicines: [med], currentRecordName: "You")
        
        // Day 0: Scheduled
        let eventsDay0 = expectedEvents[day0] ?? []
        #expect(eventsDay0.contains { $0.eventType == .dosage })
        
        // Day 1: Skipped
        let eventsDay1 = expectedEvents[day1] ?? []
        #expect(!eventsDay1.contains { $0.eventType == .dosage })
        
        // Day 2: Scheduled
        let eventsDay2 = expectedEvents[day2] ?? []
        #expect(eventsDay2.contains { $0.eventType == .dosage })
        
        // Day 3: Skipped
        let eventsDay3 = expectedEvents[day3] ?? []
        #expect(!eventsDay3.contains { $0.eventType == .dosage })
        
        // Day 4: Scheduled
        let eventsDay4 = expectedEvents[day4] ?? []
        #expect(eventsDay4.contains { $0.eventType == .dosage })
        
        // Day 5: Past end date -> Skipped
        let eventsDay5 = expectedEvents[day5] ?? []
        #expect(!eventsDay5.contains { $0.eventType == .dosage })
    }
}
