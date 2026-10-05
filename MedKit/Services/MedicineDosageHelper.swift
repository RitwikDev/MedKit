//
//  MedicineDosageHelper.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//

import SwiftUI

class MedicineDosageHelper
{
    public static func getNextDosageDate(for dosage: DosageModel, startingFrom baseDate: Date = Date()) -> Date? {
        let calendar = Calendar.current
        let baseOfDay = calendar.startOfDay(for: baseDate)
        
        // 1. Nested helper to calculate the raw next date ignoring end bounds
        func calculateRawDate() -> Date? {
            if dosage.repeatType == .custom {
                let futureDates = dosage.selectedDates.compactMap { calendar.date(from: $0) }
                    .map { calendar.startOfDay(for: $0) }
                    .filter { $0 >= baseOfDay }
                    .sorted()
                return futureDates.first
            }
            
            guard let startDate = dosage.startDate else { return nil }
            let startOfDay = calendar.startOfDay(for: startDate)
            
            if baseOfDay <= startOfDay {
                return startOfDay
            }
            
            switch dosage.repeatType {
            case .daily: return baseOfDay
            case .custom: return nil // Handled above
            case .never: return nil
                
            case .selectDays:
                var currentDate = baseOfDay
                for _ in 0..<7 {
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if let day = Day(weekdayNumber: weekday), dosage.selectedDays.contains(day) {
                        return currentDate
                    }
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                }
                return nil
                
            case .fortnightly:
                let components = calendar.dateComponents([.day], from: startOfDay, to: baseOfDay)
                let daysPassed = components.day ?? 0
                let remainder = daysPassed % 14
                let daysToNextDose = remainder == 0 ? 0 : (14 - remainder)
                return calendar.date(byAdding: .day, value: daysToNextDose, to: baseOfDay)
                
            case .monthly:
                return nextDateMatching(component: .month, interval: 1, startOfDay: startOfDay, baseOfDay: baseOfDay, calendar: calendar)
                
            case .quarterly:
                return nextDateMatching(component: .month, interval: 3, startOfDay: startOfDay, baseOfDay: baseOfDay, calendar: calendar)
                
            case .biannually:
                return nextDateMatching(component: .month, interval: 6, startOfDay: startOfDay, baseOfDay: baseOfDay, calendar: calendar)
                
            case .annually:
                return nextDateMatching(component: .year, interval: 1, startOfDay: startOfDay, baseOfDay: baseOfDay, calendar: calendar)
            }
        }
        
        // 2. Get the raw date, then validate it against the dosage.endDate
        guard let rawNextDate = calculateRawDate() else { return nil }
        
        if let endDate = dosage.endDate {
            let normalizedEndDate = calendar.startOfDay(for: endDate)
            if rawNextDate > normalizedEndDate {
                return nil // The schedule has ended before or on the baseDate
            }
        }
        
        return rawNextDate
    }
    
    // Helper to calculate exact next dates for monthly/quarterly/yearly intervals
    private static func nextDateMatching(component: Calendar.Component, interval: Int, startOfDay: Date, baseOfDay: Date, calendar: Calendar) -> Date? {
        let components = calendar.dateComponents([component], from: startOfDay, to: baseOfDay)
        let intervalsPassed = components.value(for: component) ?? 0
        let remainder = intervalsPassed % interval
        
        let intervalsToAdd = remainder == 0 ? intervalsPassed : intervalsPassed + (interval - remainder)
        var potentialNextDate = calendar.date(byAdding: component, value: intervalsToAdd, to: startOfDay)
        
        if let potential = potentialNextDate, potential < baseOfDay {
            potentialNextDate = calendar.date(byAdding: component, value: interval, to: potential)
        }
        
        return potentialNextDate
    }
    
    @MainActor
    public static func dosageSummary(
        for dosage: DosageModel,
        of medicine: Medicine
    ) -> Text {
        guard let quantity = dosage.dosageQuantity, quantity > 0 else {
            return Text(dosage.repeatType.localizedName)
        }
        
        let quantityStr = quantity.formatted(.number)
        let unitStr = medicine.stock?.unit ?? ""
        let timesCount = dosage.reminderTimes.count
        
        let repeatText: Text
        switch dosage.repeatType {
        case .selectDays:
            if dosage.selectedDays.isEmpty {
                repeatText = Text(dosage.repeatType.localizedName)
            } else {
                let joinedDays = dosage.selectedDays.map { String(localized: String.LocalizationValue($0.rawValue)) }.joined(separator: ", ")
                repeatText = Text("on \(joinedDays)")
            }
        case .custom:
            if dosage.selectedDates.isEmpty {
                repeatText = Text(dosage.repeatType.localizedName)
            } else {
                repeatText = Text("on \(dosage.selectedDates.count) selected dates")
            }
        default:
            repeatText = Text(dosage.repeatType.localizedName)
        }
        
        if timesCount <= 1 {
            return Text("\(quantityStr) \(unitStr) \(repeatText)")
        } else {
            return Text("\(quantityStr) \(unitStr), \(timesCount) times \(repeatText)")
        }
    }
}
