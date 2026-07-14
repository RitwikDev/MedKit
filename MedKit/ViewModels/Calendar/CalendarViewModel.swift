//
//  CalendarViewModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI
import Observation

@Observable
class CalendarViewModel {
    var currentMonth: Date = Date() {
        didSet {
            if let firstOfMonth = calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: currentMonth
                )
            ) {
                selectedDate = firstOfMonth
            }
        }
    }
    var selectedDate: Date = Date()
    var events: [Date: [CalendarEvent]] = [:]
    var medicines: [CalendarMedicine] = []
    
    private let calendar = Calendar.current
    
    public func initialiseMedicines() {
        do {
            try medicines = CalendarMedicineReadManager.shared.getMedicines()
            generateAllEvents()
        } catch {
            print(error)
            medicines = []
        }
    }
    
    public func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    public func generateDays(for targetDate: Date? = nil) -> [CalendarDay] {
        let referenceDate = targetDate ?? currentMonth
        
        guard let monthRange = calendar.range(of: .day, in: .month, for: referenceDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: referenceDate)) else {
            return []
        }
        
        let weekdayPadding = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [CalendarDay] = []
        
        for _ in 0..<weekdayPadding {
            days.append(CalendarDay(date: nil, dayNumber: 0))
        }
        
        for day in 1...monthRange.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(CalendarDay(date: date, dayNumber: day))
            }
        }
        
        let totalCellsNeeded = days.count <= 35 ? 35 : 42
        let trailingPadding = totalCellsNeeded - days.count
        if trailingPadding > 0 {
            for _ in 0..<trailingPadding {
                days.append(CalendarDay(date: nil, dayNumber: 0))
            }
        }
        
        return days
    }
    
    public func getEvents(forDate date: Date) -> [CalendarEvent] {
        let dateKey = calendar.startOfDay(for: date)
        return events[dateKey] ?? []
    }
    
    public func monthYearHeader(for targetDate: Date? = nil) -> String {
        let referenceDate = targetDate ?? currentMonth
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: referenceDate)
    }
    
    private func generateAllEvents() {
        events = [:]
        for medicine in medicines {
            if let expiry = medicine.expiryDate {
                
                let event: CalendarEvent = .init(
                    date: expiry,
                    title: "\(medicine.name) expiring",
                    color: .red
                )
                
                let dateKey = calendar.startOfDay(for: expiry)
                
                if events[dateKey] == nil {
                    events[dateKey] = []
                }
                
                events[dateKey]?.append(event)
            }
        }
    }
}
