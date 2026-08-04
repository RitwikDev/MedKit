//
//  MedicineStockHelper.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//

import Foundation

class MedicineStockHelper
{
    public static func calculateStockEndDate(for medicine: Medicine, startingFrom baseDate: Date = Date()) -> Date? {
        guard let stock = medicine.stock, stock.quantity > 0,
              let dosage = medicine.dosage,
              let dosageQuantity = dosage.dosageQuantity, dosageQuantity > 0,
              !dosage.reminderTimes.isEmpty else {
            return nil
        }
        
        guard let nextDosageDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: baseDate) else {
            return nil
        }
        
        let calendar = Calendar.current
        let dailyUsage = dosageQuantity * Float(dosage.reminderTimes.count)
        let totalDosesAvailable = Int(ceil(stock.quantity / dailyUsage))
        
        guard totalDosesAvailable > 0 else { return nil }
        
        let jumpsRequired = totalDosesAvailable - 1
        var rawStockEndDate = nextDosageDate
        
        if (jumpsRequired > 0) {
            switch dosage.repeatType {
            case .never:
                rawStockEndDate = nextDosageDate
                
            case .selectDays:
                var currentDate = nextDosageDate
                var remaining = jumpsRequired
                while remaining > 0 {
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    let weekday = calendar.component(.weekday, from: currentDate)
                    if let day = Day(weekdayNumber: weekday), dosage.selectedDays.contains(day) {
                        remaining -= 1
                    }
                }
                rawStockEndDate = currentDate
                
            case .fortnightly:
                rawStockEndDate = calendar.date(byAdding: .day, value: jumpsRequired * 14, to: nextDosageDate) ?? nextDosageDate
                
            case .monthly:
                rawStockEndDate = calendar.date(byAdding: .month, value: jumpsRequired, to: nextDosageDate) ?? nextDosageDate
                
            case .quarterly:
                rawStockEndDate = calendar.date(byAdding: .month, value: jumpsRequired * 3, to: nextDosageDate) ?? nextDosageDate
                
            case .biannually:
                rawStockEndDate = calendar.date(byAdding: .month, value: jumpsRequired * 6, to: nextDosageDate) ?? nextDosageDate
                
            case .annually:
                rawStockEndDate = calendar.date(byAdding: .year, value: jumpsRequired, to: nextDosageDate) ?? nextDosageDate
                
            case .custom:
                let futureDates = dosage.selectedDates.compactMap { calendar.date(from: $0) }
                    .map { calendar.startOfDay(for: $0) }
                    .filter { $0 >= nextDosageDate }
                    .sorted()
                
                if futureDates.count > jumpsRequired {
                    rawStockEndDate = futureDates[jumpsRequired]
                } else {
                    rawStockEndDate = futureDates.last ?? nextDosageDate
                }
            }
        }
        
        if let dosageEndDate = dosage.endDate {
            let normalizedDosageEndDate = calendar.startOfDay(for: dosageEndDate)
            if rawStockEndDate > normalizedDosageEndDate {
                return nil
            }
        }
        
        return rawStockEndDate
    }
}
