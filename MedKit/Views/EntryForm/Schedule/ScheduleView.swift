//
//  ScheduleView.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import SwiftUI

struct ScheduleView: View {
    @Environment(MedicineViewModel.self) private var medicineViewModel
    @Environment(\.dismiss) private var dismiss
    
    let schedule: Schedule
    @State private var repeatType: RepeatType = .never
    @State private var selectedDay: SelectedDay = .sunday
    @State private var selectedDates: Set<DateComponents> = []
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var reminderTimes: [ReminderTime] = []
    
    init(schedule: Schedule) {
        self.schedule = schedule
        self._repeatType = State(initialValue: schedule.repeatType)
        self._selectedDay = State(initialValue: schedule.selectedDay ?? .sunday)
        self._selectedDates = State(initialValue: schedule.selectedDates)
        self._startDate = State(initialValue: schedule.startDate)
        self._endDate = State(initialValue: schedule.endDate)
        self._reminderTimes = State(initialValue: schedule.reminderTimes)
    }
    
    var body: some View {
        Form {
            Section("Frequency") {
                repeatTypePickerView
                
                if (repeatType == .weekly || repeatType == .fortnightly) {
                    dayPickerView
                } else if (repeatType == .custom) {
                    MultiDatePicker("Select Dates", selection: $selectedDates)
                }
            }
            
            if (repeatType != .custom) {
                Section("Dates") {
                    DatePickerView(
                        label: "\(startDate == nil ? "Add Start Date" : "Start Date")",
                        date: $startDate
                    )
                    .onChange(of: startDate) { oldValue, newValue in
                        guard let newDate = newValue else { return }
                        
                        let weekdayNumber = Calendar.current.component(.weekday, from: newDate)
                        
                        if let matchedDay = SelectedDay(weekdayNumber: weekdayNumber) {
                            self.selectedDay = matchedDay
                        }
                    }
                    
                    DatePickerView(
                        label: "\(startDate == nil ? "Add End Date" : "End Date")",
                        date: $endDate
                    )
                }
            }
            
            Section("Time") {
                ForEach($reminderTimes, id: \.self) { $reminderTime in
                    timePickerView(reminderTime: $reminderTime.time)
                }
                .onDelete(perform: DeleteReminderTime)
                
                Button("Add Time") { onAddTime() }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Done") {
                    let schedule = Schedule(
                        startDate: startDate,
                        endDate: endDate,
                        reminderTimes: reminderTimes,
                        repeatType: repeatType,
                        selectedDay: selectedDay,
                        selectedDates: selectedDates
                    )
                    
                    medicineViewModel.medicine.schedule = schedule
                    dismiss()
                }
            }
        }
        .navigationTitle("Add Schedule")
    }
    
    private var repeatTypePickerView: some View {
        Picker("Repeat",
               selection: $repeatType.animation()) {
            ForEach(RepeatType.allCases) { repeatType in
                Text(repeatType.rawValue).tag(repeatType)
            }
        }
    }
    
    private var dayPickerView: some View {
        Picker("Every",
               selection: $selectedDay) {
            ForEach(SelectedDay.allCases) { selectedDay in
                Text(selectedDay.rawValue).tag(selectedDay)
            }
        }
    }
    
    private func timePickerView(reminderTime: Binding<Date>) -> some View {
        DatePicker("Remind At", selection: reminderTime, displayedComponents: .hourAndMinute)
    }

    
    private func onAddTime() {
        withAnimation {
            reminderTimes.append(.init(time: .now))
        }
    }
    
    private func DeleteReminderTime(at offsets: IndexSet) {
        withAnimation {
            self.reminderTimes.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    ScheduleView(schedule: .init())
        .environment(MedicineViewModel())
}
