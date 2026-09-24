//
//  MedicineStockEndDateCalculator.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//

import Foundation

class MedicineStockEndDateCalculator
{
    public static func calculate(
        stock: StockModel?,
        dosage: DosageModel?,
        startingFrom baseDate: Date? = nil
    ) -> Date? {
        guard let stock = stock,
              stock.quantity > 0,
              let dosage = dosage,
              let dosageQuantity = dosage.dosageQuantity,
              dosageQuantity > 0,
              !dosage.reminderTimes.isEmpty else {
            return nil
        }
        
        let actualBaseDate = baseDate ?? max(Date(), dosage.startDate ?? Date())
        guard let nextDosageDate = MedicineDosageHelper.getNextDosageDate(for: dosage, startingFrom: actualBaseDate) else {
            return nil
        }
        
        let calendar = Calendar.current
        let dailyUsage = dosageQuantity * Float(dosage.reminderTimes.count)
        let fullDaysCovered = Int(floor(stock.quantity / dailyUsage))
        
        // If they don't even have enough for the first dose, stockout is immediately on nextDosageDate
        if fullDaysCovered == 0 {
            return nextDosageDate
        }
        
        // At this point, fullDaysCovered >= 1, so they can take at least 1 dose.
        let jumpsRequired = fullDaysCovered - 1
        var rawStockEndDate = nextDosageDate
        
        switch dosage.repeatType {
        case .never:
            // Since fullDaysCovered >= 1, they have enough for this single dose.
            return nil
            
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
            
            // If the total scheduled future dates <= fullDaysCovered, they don't run out.
            if futureDates.count > fullDaysCovered {
                rawStockEndDate = futureDates[jumpsRequired] // futureDates[fullDaysCovered - 1]
            } else {
                return nil
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
