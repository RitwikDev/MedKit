//
//  DosageViewExtension.swift
//  MedKit
//
//  Created by Rishik Dev on 03/07/26.
//

import Foundation
import SwiftUI

extension DosageView {    
    func handleFortnightlyDayChange(
        draftDosage: Binding<DosageModel>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        if draftDosage.wrappedValue.startDate != nil {
            handleDateChange(
                to: draftDosage.wrappedValue.startDate,
                for: .startDate,
                draftDosage: draftDosage,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
        if draftDosage.wrappedValue.endDate != nil {
            handleDateChange(
                to: draftDosage.wrappedValue.endDate,
                for: .endDate,
                draftDosage: draftDosage,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
    }
    
    func toggleSelectedDay(
        _ day: Day,
        draftDosage: Binding<DosageModel>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        if draftDosage.wrappedValue.selectedDays.contains(day) {
            draftDosage.wrappedValue.selectedDays.removeAll { $0 == day }
        } else {
            draftDosage.wrappedValue.selectedDays.append(day)
        }
        
        guard !draftDosage.wrappedValue.selectedDays.isEmpty else { return }
        
        if draftDosage.wrappedValue.startDate != nil {
            handleDateChange(
                to: draftDosage.wrappedValue.startDate,
                for: .startDate,
                draftDosage: draftDosage,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
        if draftDosage.wrappedValue.endDate != nil {
            handleDateChange(
                to: draftDosage.wrappedValue.endDate,
                for: .endDate,
                draftDosage: draftDosage,
                selectedDay: selectedDay,
                showToast: showToast,
                toastMessage: toastMessage
            )
        }
    }
    
    func handleDateChange(
        to newValue: Date?,
        for type: DateType,
        draftDosage: Binding<DosageModel>,
        selectedDay: Binding<Day>,
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        guard let newDate = newValue else { return }
        let calendar = Calendar.current
        
        // NEW: Determine which array to validate against based on RepeatType
        let repeatType = draftDosage.wrappedValue.repeatType
        let validDays = repeatType == .fortnightly ? [selectedDay.wrappedValue] : draftDosage.wrappedValue.selectedDays
        
        // 1. Initial Boundary Check (End Date Only)
        if type == .endDate {
            if let startDate = draftDosage.wrappedValue.startDate, calendar.startOfDay(for: newDate) < calendar.startOfDay(for: startDate) {
                autoAdvanceEndDate(
                    from: startDate,
                    message: "Ensure the end date is after the start date. It has been adjusted automatically.",
                    draftDosage: draftDosage,
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
                    if type == .endDate, let startDate = draftDosage.wrappedValue.startDate, calendar.startOfDay(for: correctedDate) < calendar.startOfDay(for: startDate) {
                        autoAdvanceEndDate(
                            from: startDate,
                            message: "End date auto-adjusted to remain after start date.",
                            draftDosage: draftDosage,
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
                draftDosage.wrappedValue.startDate = finalDate
                
                if let endDate = draftDosage.wrappedValue.endDate, calendar.startOfDay(for: finalDate) > calendar.startOfDay(for: endDate) {
                    autoAdvanceEndDate(
                        from: finalDate,
                        message: "End date was automatically advanced.",
                        draftDosage: draftDosage,
                        validDays: validDays, // Pass the correct array
                        showToast: showToast,
                        toastMessage: toastMessage
                    )
                }
            } else {
                draftDosage.wrappedValue.endDate = finalDate
            }
        }
    }
    
    // NEW: added `validDays` parameter
    func autoAdvanceEndDate(
        from baseDate: Date,
        message: String,
        draftDosage: Binding<DosageModel>,
        validDays: [Day],
        showToast: Binding<Bool>,
        toastMessage: Binding<String>
    ) {
        let calendar = Calendar.current
        if let advancedEndDate = calendar.date(byAdding: .day, value: 7, to: baseDate) {
            
            // It will safely fallback to advancedEndDate if validDays is empty
            let snappedEndDate = nearestValidDate(from: advancedEndDate, validDays: validDays, searchForward: true) ?? advancedEndDate
            
            displayToast(message, showToast: showToast, toastMessage: toastMessage)
            Task { @MainActor in draftDosage.wrappedValue.endDate = snappedEndDate }
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

    func onAddTime(draftDosage: inout DosageModel) {
        withAnimation {
            draftDosage.reminderTimes.append(.init(time: .now))
        }
    }
    
    func deleteReminderTime(at offsets: IndexSet, draftDosage: inout DosageModel) {
        withAnimation {
            draftDosage.reminderTimes.remove(atOffsets: offsets)
        }
    }
    
    func handleDoneButtonTap(
        medicineEditorViewModel: MedicineEditorViewModel,
        draftDosage: inout DosageModel,
        selectedDay: Day,
        selectedDates: Set<DateComponents>,
    ) {
        if (draftDosage.repeatType == .fortnightly) {
            draftDosage.selectedDays = [selectedDay]
        }
        draftDosage.selectedDates = Array(selectedDates)
        medicineEditorViewModel.medicine.dosage = draftDosage
    }
}
