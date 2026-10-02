//
//  ScheduleGenerationService.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//

import Foundation
import SwiftUI

actor ScheduleGenerationService: ScheduleGenerationServiceProtocol {
    private let calendar = Calendar.current
    
    func generateEvents(for targetMonth: Date, medicines: [CalendarMedicine], currentRecordName: String) -> [Date: [CalendarEvent]] {
        var computedEvents: [Date: [CalendarEvent]] = [:]
        
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: targetMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: firstOfMonth) else {
            return computedEvents
        }
        
        let daysInMonth = monthRange.count
        
        for medicine in medicines {
            // 1. Expiry Events
            if let expiry = medicine.expiryDate, calendar.isDate(expiry, equalTo: targetMonth, toGranularity: .month) {
                let event = CalendarEvent(date: expiry, title: String(localized: "Expiring: \(medicine.name)"), color: .red, eventType: .expiry)
                let dateKey = calendar.startOfDay(for: expiry)
                computedEvents[dateKey, default: []].append(event)
            }
            
            // 2. Stock End Events
            let stockEndDate = medicine.stock?.endDate ?? .distantFuture
            if calendar.isDate(stockEndDate, equalTo: targetMonth, toGranularity: .month) {
                let event = CalendarEvent(date: stockEndDate, title: String(localized: "Stockout: \(medicine.name)"), color: .red, eventType: .stockout)
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
                            
                            appendReminderEvents(for: medicine, dosage: dosage, on: normalizedScheduledDate, dayComponents: eventDateComponents, currentRecordName: currentRecordName, into: &computedEvents)
                        }
                    }
                } else if let startDate = dosage.startDate {
                    let dosageEndDate = dosage.endDate ?? .distantFuture
                    let effectiveEndDate = dosageEndDate
                    
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
                            appendReminderEvents(for: medicine, dosage: dosage, on: normalizedCurrentDate, dayComponents: dayComponents, currentRecordName: currentRecordName, into: &computedEvents)
                        }
                    }
                }
            }
        }
        
        return computedEvents
    }
    
    private func appendReminderEvents(for medicine: CalendarMedicine, dosage: DosageModel, on targetDate: Date, dayComponents: DateComponents, currentRecordName: String, into eventsDict: inout [Date: [CalendarEvent]]) {
        for reminder in dosage.reminderTimes {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: reminder.time)
            var eventDateComponents = dayComponents
            eventDateComponents.hour = timeComponents.hour
            eventDateComponents.minute = timeComponents.minute
            
                        if let finalEventDate = calendar.date(from: eventDateComponents) {
                let isTaken = medicine.doseLogs.contains(where: { 
                    calendar.isDate($0.date, equalTo: finalEventDate, toGranularity: .minute) &&
                    ($0.takenByUserName == currentRecordName || $0.takenByUserName == "You" || currentRecordName == "You")
                })
                
                let title = isTaken ? String(localized: "\(medicine.name) taken") : String(localized: "Take \(medicine.name)")
                let color: SwiftUI.Color = isTaken ? .green : .blue
                
                let event = CalendarEvent(
                    date: finalEventDate,
                    title: title,
                    color: color,
                    medicineID: medicine.id,
                    isTaken: isTaken,
                    takenByUserID: nil,
                    eventType: .dosage
                )
                eventsDict[targetDate, default: []].append(event)
            }
        }
    }
    private func isMedicineScheduled(on targetDate: Date, for dosage: DosageModel, startDate: Date) -> Bool {
        switch dosage.repeatType {
        case .daily:
            return true
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
            let monthsDiff = monthsBetween(startDate, and: targetDate)
            guard monthsDiff >= 0 else { return false }
            let expectedDate = calendar.date(byAdding: .month, value: monthsDiff, to: startDate)
            return expectedDate == targetDate
            
        case .quarterly:
            let monthsDiff = monthsBetween(startDate, and: targetDate)
            guard monthsDiff >= 0, monthsDiff % 3 == 0 else { return false }
            let expectedDate = calendar.date(byAdding: .month, value: monthsDiff, to: startDate)
            return expectedDate == targetDate
            
        case .biannually:
            let monthsDiff = monthsBetween(startDate, and: targetDate)
            guard monthsDiff >= 0, monthsDiff % 6 == 0 else { return false }
            let expectedDate = calendar.date(byAdding: .month, value: monthsDiff, to: startDate)
            return expectedDate == targetDate
            
        case .annually:
            let startYear = calendar.component(.year, from: startDate)
            let targetYear = calendar.component(.year, from: targetDate)
            let yearsDiff = targetYear - startYear
            guard yearsDiff >= 0 else { return false }
            let expectedDate = calendar.date(byAdding: .year, value: yearsDiff, to: startDate)
            return expectedDate == targetDate
            
        case .custom:
            return false // Custom is handled directly in the outer loops
        }
    }
    
    /// Calculates the discrete number of calendar months between two dates
    private func monthsBetween(_ start: Date, and target: Date) -> Int {
        let startComponents = calendar.dateComponents([.year, .month], from: start)
        let targetComponents = calendar.dateComponents([.year, .month], from: target)
        
        let startYear = startComponents.year ?? 0
        let startMonth = startComponents.month ?? 0
        let targetYear = targetComponents.year ?? 0
        let targetMonth = targetComponents.month ?? 0
        
        return (targetYear - startYear) * 12 + (targetMonth - startMonth)
    }

}
