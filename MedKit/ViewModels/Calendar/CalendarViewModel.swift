//
//  CalendarViewModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI
import Observation

@Observable
@MainActor
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
    
    var currentRecordName: String = "You"
    var selectedDate: Date = Date()
    var events: [Date: [CalendarEvent]] = [:]
    var medicines: [CalendarMedicine] = []
    
    private let calendar = Calendar.current
    private let scheduleService = ScheduleGenerationService() // Inject the background actor
    private var eventGenerationTask: Task<Void, Never>?
    
    private func fetchRecordName() {
        Task {
            let name = await GlobalDataManager.shared.fetchCurrentRecordName() ?? "You"
            await MainActor.run {
                self.currentRecordName = name
                self.triggerEventGeneration()
            }
        }
    }
    
    public func initialiseMedicines() {
        fetchRecordName()
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
        
        eventGenerationTask?.cancel()
        
        eventGenerationTask = Task {
            // Await the actor's heavy calculation in the background
            let newEvents = await scheduleService.generateEvents(for: targetMonth, medicines: currentMedicines, currentRecordName: self.currentRecordName)
            
            // Allow cancellation check
            guard !Task.isCancelled else { return }
            
            // Assign the result back on the Main thread
            await MainActor.run {
                if self.currentMonth == targetMonth {
                    self.events = newEvents
                }
            }
        }
    }
    
    public func toggleDoseLog(for event: CalendarEvent) {
        guard event.eventType == .dosage, let medicineID = event.medicineID else { return }
        let isTaken = !event.isTaken
        let date = event.date
        
        Task {
            do {
                let localID = self.currentRecordName
                let medicine = try MedicineReadManager.shared.fetchById(medicineID)
                var updatedLogs = medicine.doseLogs
                
                if let idx = updatedLogs.firstIndex(where: { 
                    Calendar.current.isDate($0.date, equalTo: date, toGranularity: .minute) &&
                    ($0.takenByUserName == localID || $0.takenByUserName == "You" || localID == "You")
                }) {
                    if isTaken {
                        updatedLogs[idx].isTaken = true
                        updatedLogs[idx].takenByUserName = localID
                    } else {
                        updatedLogs.remove(at: idx)
                    }
                } else if isTaken {
                    updatedLogs.append(DoseLogModel(date: date, isTaken: true, takenByUserName: localID))
                }
                
                var mutableMedicine = medicine
                mutableMedicine.doseLogs = updatedLogs
                
                try MedicineWriteManager.shared.save(mutableMedicine)
                
                await MainActor.run {
                    self.initialiseMedicines() // Reload data and regenerate events
                }
            } catch {
                print("Failed to toggle dose log: \(error)")
            }
        }
    }
}