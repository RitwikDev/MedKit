//
//  CalendarUIHelper.swift
//  MedKit
//
//  Created by Ritwik Dev on 03/08/26.
//


import Foundation

struct CalendarUIHelper {
    static let calendar = Calendar.current
    
    static func generateDays(for targetDate: Date) -> [CalendarDay] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: targetDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: targetDate)) else {
            return []
        }
        
        let weekdayPadding = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [CalendarDay] = []
        
        // Add leading empty cells
        for _ in 0..<weekdayPadding {
            days.append(CalendarDay(date: nil, dayNumber: 0))
        }
        
        // Add actual days
        for day in 1...monthRange.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(CalendarDay(date: date, dayNumber: day))
            }
        }
        
        // Add trailing empty cells to complete the grid (35 or 42 cells)
        let totalCellsNeeded = days.count <= 35 ? 35 : 42
        let trailingPadding = totalCellsNeeded - days.count
        if trailingPadding > 0 {
            for _ in 0..<trailingPadding {
                days.append(CalendarDay(date: nil, dayNumber: 0))
            }
        }
        
        return days
    }
    
    static func monthYearHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
