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
            updateSelectedDateToFirstOfMonth()
            triggerEventGeneration()
        }
    }
    
    public func daysForMonth(of date: Date) -> [CalendarDay] {
        CalendarUIHelper.generateDays(for: date)
    }
    
    public func monthYearHeaderString(for date: Date) -> String {
        CalendarUIHelper.monthYearHeader(for: date)
    }
    
    var selectedDate: Date = Date()
    var events: [Date: [CalendarEvent]] = [:]
    var medicines: [CalendarMedicine] = []
    
    private let calendar = Calendar.current
    private let scheduleService = ScheduleGenerationService() // Inject the background actor
    
    public func initialiseMedicines() {
        do {
            try medicines = CalendarMedicineReadManager.shared.getMedicines()
            triggerEventGeneration()
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
    
    public func getEvents(forDate date: Date) -> [CalendarEvent] {
        let dateKey = calendar.startOfDay(for: date)
        let dayEvents = events[dateKey] ?? []
        
        return dayEvents.sorted { $0.date < $1.date }
    }
    
    // MARK: - Private Helpers
    
    private func updateSelectedDateToFirstOfMonth() {
        if let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) {
            selectedDate = firstOfMonth
        }
    }
    
    private func triggerEventGeneration() {
        let targetMonth = currentMonth
        let currentMedicines = medicines
        
        Task {
            // Await the actor's heavy calculation in the background
            let newEvents = await scheduleService.generateEvents(for: targetMonth, medicines: currentMedicines)
            
            // Assign the result back on the Main thread
            await MainActor.run {
                self.events = newEvents
            }
        }
    }
}
