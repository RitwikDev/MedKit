//
//  ScheduleGenerationService.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//


import Foundation

actor ScheduleGenerationService {
    private let calendar = Calendar.current
    
    func generateEvents(for targetMonth: Date, medicines: [CalendarMedicine]) -> [Date: [CalendarEvent]] {
        var computedEvents: [Date: [CalendarEvent]] = [:]
        
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: targetMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return computedEvents
        }
        
        let daysInMonth = monthRange.count
        
        for medicine in medicines {
            // 1. Expiry Events
            if let expiry = medicine.expiryDate, calendar.isDate(expiry, equalTo: targetMonth, toGranularity: .month) {
                let event = CalendarEvent(date: expiry, title: "Expiring: \(medicine.name)", color: .red)
                let dateKey = calendar.startOfDay(for: expiry)
                computedEvents[dateKey, default: []].append(event)
            }
            
            // 2. Stock End Events
            let stockEndDate = medicine.stock.endDate
            if calendar.isDate(stockEndDate, equalTo: targetMonth, toGranularity: .month) {
                let event = CalendarEvent(date: stockEndDate, title: "Stockout: \(medicine.name)", color: .red)
                let dateKey = calendar.startOfDay(for: stockEndDate)
                computedEvents[dateKey, default: []].append(event)
            }
            
            // 3. Schedule Events
            if let dosage = medicine.dosage {
                if dosage.repeatType == .custom {
                    for selectedDate in dosage.selectedDates {
                        if selectedDate.year == calendar.component(.year, from: targetMonth) &&
                            selectedDate.month == calendar.component(.month, from: targetMonth),
                           let day = selectedDate.day {
                            
                            var eventDateComponents = calendar.dateComponents([.year, .month], from: firstOfMonth)
                            eventDateComponents.day = day
                            
                            guard let scheduledDate = calendar.date(from: eventDateComponents) else { continue }
                            let normalizedScheduledDate = calendar.startOfDay(for: scheduledDate)
                            
                            appendReminderEvents(for: medicine, dosage: dosage, on: normalizedScheduledDate, dayComponents: eventDateComponents, into: &computedEvents)
                        }
                    }
                } else if let startDate = dosage.startDate {
                    let dosageEndDate = dosage.endDate ?? .distantFuture
                    let effectiveEndDate = min(stockEndDate, dosageEndDate)
                    
                    let normalizedStartDate = calendar.startOfDay(for: startDate)
                    let normalizedEffectiveEndDate = calendar.startOfDay(for: effectiveEndDate)
                    
                    var dayComponents = calendar.dateComponents([.year, .month], from: firstOfMonth)
                    
                    for day in 1...daysInMonth {
                        dayComponents.day = day
                        guard let currentDate = calendar.date(from: dayComponents) else { continue }
                        let normalizedCurrentDate = calendar.startOfDay(for: currentDate)
                        
                        if normalizedCurrentDate < normalizedStartDate || normalizedCurrentDate > normalizedEffectiveEndDate {
                            continue
                        }
                        
                        if isMedicineScheduled(on: normalizedCurrentDate, for: dosage, startDate: normalizedStartDate) {
                            appendReminderEvents(for: medicine, dosage: dosage, on: normalizedCurrentDate, dayComponents: dayComponents, into: &computedEvents)
                        }
                    }
                }
            }
        }
        
        return computedEvents
    }
    
    private func appendReminderEvents(for medicine: CalendarMedicine, dosage: DosageModel, on targetDate: Date, dayComponents: DateComponents, into eventsDict: inout [Date: [CalendarEvent]]) {
        for reminder in dosage.reminderTimes {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: reminder.time)
            var eventDateComponents = dayComponents
            eventDateComponents.hour = timeComponents.hour
            eventDateComponents.minute = timeComponents.minute
            
            if let finalEventDate = calendar.date(from: eventDateComponents) {
                let event = CalendarEvent(date: finalEventDate, title: "Take \(medicine.name)", color: .blue)
                eventsDict[targetDate, default: []].append(event)
            }
        }
    }
    
    private func isMedicineScheduled(on targetDate: Date, for dosage: DosageModel, startDate: Date) -> Bool {
        switch dosage.repeatType {
        case .never:
            return targetDate == startDate
        case .selectDays:
            let weekday = calendar.component(.weekday, from: targetDate)
            guard let day = Day(weekdayNumber: weekday) else { return false }
            return dosage.selectedDays.contains(day)
        case .fortnightly:
            let components = calendar.dateComponents([.day], from: startDate, to: targetDate)
            guard let daysDifference = components.day else { return false }
            return daysDifference % 14 == 0
        case .monthly:
            return calendar.component(.day, from: startDate) == calendar.component(.day, from: targetDate)
        case .quarterly:
            let components = calendar.dateComponents([.month, .day], from: startDate, to: targetDate)
            guard let monthsDifference = components.month else { return false }
            return monthsDifference % 3 == 0 && calendar.component(.day, from: startDate) == calendar.component(.day, from: targetDate)
        case .biannually:
            let components = calendar.dateComponents([.month, .day], from: startDate, to: targetDate)
            guard let monthsDifference = components.month else { return false }
            return monthsDifference % 6 == 0 && calendar.component(.day, from: startDate) == calendar.component(.day, from: targetDate)
        case .annually:
            let startComponents = calendar.dateComponents([.month, .day], from: startDate)
            let targetComponents = calendar.dateComponents([.month, .day], from: targetDate)
            return startComponents.month == targetComponents.month && startComponents.day == targetComponents.day
        case .custom:
            return false
        }
    }
}
