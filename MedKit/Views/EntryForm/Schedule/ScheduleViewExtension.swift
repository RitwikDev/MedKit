//
//  ScheduleViewExtension.swift
//  MedKit
//
//  Created by Rishik Dev on 03/07/26.
//

import Foundation
import SwiftUI

extension ScheduleView {    
    func handleFortnightlyDayChange(
        draftSchedule: Binding<Schedule>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        if draftSchedule.wrappedValue.startDate != nil {
            handleDateChange(
                to: draftSchedule.wrappedValue.startDate,
                for: .startDate,
                draftSchedule: draftSchedule,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
        if draftSchedule.wrappedValue.endDate != nil {
            handleDateChange(
                to: draftSchedule.wrappedValue.endDate,
                for: .endDate,
                draftSchedule: draftSchedule,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
    }
    
    func toggleSelectedDay(
        _ day: Day,
        draftSchedule: Binding<Schedule>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        if draftSchedule.wrappedValue.selectedDays.contains(day) {
            draftSchedule.wrappedValue.selectedDays.removeAll { $0 == day }
        } else {
            draftSchedule.wrappedValue.selectedDays.append(day)
        }
        
        guard !draftSchedule.wrappedValue.selectedDays.isEmpty else { return }
        
        if draftSchedule.wrappedValue.startDate != nil {
            handleDateChange(
                to: draftSchedule.wrappedValue.startDate,
                for: .startDate,
                draftSchedule: draftSchedule,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
        if draftSchedule.wrappedValue.endDate != nil {
            handleDateChange(
                to: draftSchedule.wrappedValue.endDate,
                for: .endDate,
                draftSchedule: draftSchedule,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
    }
    
    func handleDateChange(
        to newValue: Date?,
        for type: DateType,
        draftSchedule: Binding<Schedule>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        guard let newDate = newValue else { return }
        let calendar = Calendar.current
        
        // NEW: Determine which array to validate against based on RepeatType
        let repeatType = draftSchedule.wrappedValue.repeatType
        let validDays = repeatType == .fortnightly ? [selectedDay.wrappedValue] : draftSchedule.wrappedValue.selectedDays
        
        // 1. Initial Boundary Check (End Date Only)
        if type == .endDate {
            if let startDate = draftSchedule.wrappedValue.startDate, calendar.startOfDay(for: newDate) < calendar.startOfDay(for: startDate) {
                autoAdvanceEndDate(
                    from: startDate,
                    message: "End date must be after start date. Adjusted automatically.",
                    draftSchedule: draftSchedule,
                    validDays: validDays, // Pass the correct array
                    showToast: showToast,
                    toastMessage: toastMessage
                )
                return
            }
        }
        
        // 2. Snapping Logic
        let weekdayNumber = calendar.component(.weekday, from: newDate)
        var finalDate = newDate
        
        // NEW: Ensure snapping only happens for these two specific repeat types
        if let matchedDay = Day(weekdayNumber: weekdayNumber),
           (repeatType == .selectDays || repeatType == .fortnightly),
           !validDays.isEmpty {
            
            if !validDays.contains(matchedDay) {
                let searchForward = (type == .startDate)
                
                if let correctedDate = nearestValidDate(from: newDate, validDays: validDays, searchForward: searchForward) {
                    
                    // Post-snap boundary check (End Date Only)
                    if type == .endDate, let startDate = draftSchedule.wrappedValue.startDate, calendar.startOfDay(for: correctedDate) < calendar.startOfDay(for: startDate) {
                        autoAdvanceEndDate(
                            from: startDate,
                            message: "End date auto-adjusted to remain after start date.",
                            draftSchedule: draftSchedule,
                            validDays: validDays, // Pass the correct array
                            showToast: showToast,
                            toastMessage: toastMessage
                        )
                        return
                    }
                    
                    finalDate = correctedDate
                    displayToast(
                        "\(type == .startDate ? "Start" : "End") date adjusted to the \(searchForward ? "next" : "previous") valid day.",
                        showToast: showToast,
                        toastMessage: toastMessage
                    )
                }
            } else if type == .startDate && repeatType == .selectDays {
                // Only sync this for .selectDays, fortnightly already manages selectedDay
                selectedDay.wrappedValue = matchedDay
            }
        }
        
        // 3. State Assignment & Start Date Overtake Check
        Task { @MainActor in
            if type == .startDate {
                draftSchedule.wrappedValue.startDate = finalDate
                
                if let endDate = draftSchedule.wrappedValue.endDate, calendar.startOfDay(for: finalDate) > calendar.startOfDay(for: endDate) {
                    autoAdvanceEndDate(
                        from: finalDate,
                        message: "End date was automatically advanced.",
                        draftSchedule: draftSchedule,
                        validDays: validDays, // Pass the correct array
                        showToast: showToast,
                        toastMessage: toastMessage
                    )
                }
            } else {
                draftSchedule.wrappedValue.endDate = finalDate
            }
        }
    }
    
    // NEW: added `validDays` parameter
    func autoAdvanceEndDate(
        from baseDate: Date,
        message: String,
        draftSchedule: Binding<Schedule>,
        validDays: [Day],
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        let calendar = Calendar.current
        if let advancedEndDate = calendar.date(byAdding: .day, value: 7, to: baseDate) {
            
            // It will safely fallback to advancedEndDate if validDays is empty
            let snappedEndDate = nearestValidDate(from: advancedEndDate, validDays: validDays, searchForward: true) ?? advancedEndDate
            
            displayToast(message, showToast: showToast, toastMessage: toastMessage)
            Task { @MainActor in draftSchedule.wrappedValue.endDate = snappedEndDate }
        }
    }
    
    func nearestValidDate(from date: Date, validDays: [Day], searchForward: Bool) -> Date? {
        guard !validDays.isEmpty else { return date }
        
        let calendar = Calendar.current
        var currentDate = date
        let step = searchForward ? 1 : -1
        
        for _ in 0..<7 {
            let weekdayNumber = calendar.component(.weekday, from: currentDate)
            
            if let currentDay = Day(weekdayNumber: weekdayNumber), validDays.contains(currentDay) {
                return currentDate
            }
            
            if let nextDate = calendar.date(byAdding: .day, value: step, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return nil
    }
    
    func displayToast(
        _ message: String,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        toastMessage.wrappedValue = message
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast.wrappedValue = true
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 3_500_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showToast.wrappedValue = false
                }
            }
        }
    }

    func onAddTime(draftSchedule: inout Schedule) {
        withAnimation {
            draftSchedule.reminderTimes.append(.init(time: .now))
        }
    }
    
    func deleteReminderTime(at offsets: IndexSet, draftSchedule: inout Schedule) {
        withAnimation {
            draftSchedule.reminderTimes.remove(atOffsets: offsets)
        }
    }
    
    func handleDoneButtonTap(
        medicineEditorViewModel: MedicineEditorViewModel,
        draftSchedule: inout Schedule,
        selectedDay: Day,
        selectedDates: Set<DateComponents>,
    ) {
        if (draftSchedule.repeatType == .fortnightly) {
            draftSchedule.selectedDays = [selectedDay]
        }
        draftSchedule.selectedDates = Array(selectedDates)
        medicineEditorViewModel.medicine.schedule = draftSchedule
    }
}
