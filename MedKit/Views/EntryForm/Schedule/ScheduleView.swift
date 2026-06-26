//
//  ScheduleView.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import SwiftUI

struct ScheduleView: View {
    let schedule: Schedule
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var repeatType: RepeatType = .never
    @State private var selectedDay: Day = .sunday
    @State private var selectedDays: [Day] = []
    @State private var selectedDates: Set<DateComponents> = []
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var reminderTimes: [ReminderTime] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(schedule: Schedule, medicineEditorViewModel: MedicineEditorViewModel) {
        self.schedule = schedule
        self.medicineEditorViewModel = medicineEditorViewModel
        
        self._repeatType = State(initialValue: schedule.repeatType)
        self._selectedDay = State(initialValue: schedule.selectedDays.first ?? .sunday)
        self._selectedDays = State(initialValue: schedule.selectedDays)
        self._selectedDates = State(initialValue: Set(schedule.selectedDates))
        self._startDate = State(initialValue: schedule.startDate)
        self._endDate = State(initialValue: schedule.endDate)
        self._reminderTimes = State(initialValue: schedule.reminderTimes)
    }
    
    private var isDoneButtonDisabled: Bool {
        switch repeatType {
        case .never:
            if ((startDate != nil && reminderTimes.isEmpty)
                || (startDate == nil && !reminderTimes.isEmpty)
            ) {
                return true
            }
        case .selectDays:
            if (selectedDays.isEmpty || reminderTimes.isEmpty) {
                return true
            }
        case .fortnightly:
            if (reminderTimes.isEmpty) {
                return true
            }
        case .monthly, .quarterly, .biannually, .annually:
            if (startDate == nil || reminderTimes.isEmpty) {
                return true
            }
        case .custom:
            if (selectedDates.isEmpty || reminderTimes.isEmpty) {
                return true
            }
        }
        
        return false
    }
    
    var body: some View {
        Form {
            frequencyPickerSectionView
            conditionalSelectorSectionView
            datePickerSectionView
            timePickerSectionView
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: handleDoneButtonTap)
                    .disabled(isDoneButtonDisabled)
            }
        }
        .alert("Schedule is incomplete!", isPresented: $showAlert) {
            Button("Dismiss") { }
        } message: {
            Text(alertMessage)
        }
        .navigationTitle("Add Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var frequencyPickerSectionView: some View {
        Section("Frequency") {
            Picker("Repeat",
                   selection: $repeatType.animation()) {
                ForEach(RepeatType.allCases) { repeatType in
                    Text(repeatType.rawValue)
                        .tag(repeatType)
                }
            }
                   .onChange(of: repeatType) { _, newValue in
                       selectedDay = .sunday
                       selectedDays = []
                       selectedDates = []
                       startDate = nil
                       endDate = nil
                       reminderTimes = newValue == .never ? []: [.init(time: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!)]
                   }
        }
    }
    
    @ViewBuilder
    private var conditionalSelectorSectionView: some View {
        switch repeatType {
        case .never, .monthly, .quarterly, .biannually, .annually:
            EmptyView()
        case .selectDays:
            selectDaysView
        case .fortnightly:
            fortnightlyView
        case .custom:
            customView
        }
    }
    
    private var selectDaysView: some View {
        Section("Days (Required)") {
            ForEach(Day.allCases) { day in
                Button {
                    withAnimation {
                        if (selectedDays.contains(day)) {
                            selectedDays.removeAll { $0 == day }
                        } else {
                            selectedDays.append(day)
                        }
                    }
                } label: {
                    HStack {
                        Text(day.rawValue)
                        
                        if (selectedDays.contains(day)) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .tint(.primary)
            }
        }
    }
    
    private var fortnightlyView: some View {
        Section("Day") {
            Picker("Remind On", selection: $selectedDay) {
                ForEach(Day.allCases) { day in
                    Text(day.rawValue)
                        .tag(day)
                }
            }
        }
    }
    
    private var customView: some View {
        Section("Dates (Required)") {
            MultiDatePicker("Select Dates", selection: $selectedDates)
        }
    }
    
    private var datesSectionView: some View {
        Section(content: {
            DatePickerView(
                label: "\(startDate == nil ? "Add Start Date" : "Start Date")",
                date: $startDate
            )
            .onChange(of: startDate) { _, newValue in
                // Changing the selectedDay to match the day of the current startDate
                guard let newDate = newValue else { return }
                
                let weekdayNumber = Calendar.current.component(.weekday, from: newDate)
                
                if let matchedDay = Day(weekdayNumber: weekdayNumber) {
                    self.selectedDay = matchedDay
                }
            }
            
            DatePickerView(
                label: "\(startDate == nil ? "Add End Date" : "End Date")",
                date: $endDate
            )
        }, header: {
            Text("Dates")
        }, footer: {
            if (startDate == nil) {
                if (repeatType == .selectDays) {
                    if (!selectedDays.isEmpty) {
                        Text("A start date is not added. Reminders will be sent every week starting \(selectedDays[0].rawValue).")
                    }
                } else if (repeatType == .fortnightly) {
                    Text("A start date is not added. Reminders will be sent every two weeks starting \(selectedDay.rawValue).")
                } else {
                    Text("A start date is required.")
                }
            }
        })
    }
    
    private var dateSectionView: some View {
        Section("Date") {
            DatePickerView(
                label: "\(startDate == nil ? "Add Date" : "Remind On")",
                date: $startDate
            )
        }
    }
    
    @ViewBuilder
    private var datePickerSectionView: some View {
        switch repeatType {
        case .never:
            dateSectionView
        case .custom:
            EmptyView()
        default:
            datesSectionView
        }
    }
    
    private var timePickerSectionView: some View {
        Section("Times") {
            ForEach($reminderTimes) { $reminderTime in
                DatePicker(
                    "Remind At",
                    selection: $reminderTime.time,
                    displayedComponents: .hourAndMinute
                )
            }
            .onDelete(perform: deleteReminderTime)
            
            Button("Add Time") { onAddTime() }
        }
    }

    private func onAddTime() {
        withAnimation {
            reminderTimes.append(.init(time: .now))
        }
    }
    
    private func deleteReminderTime(at offsets: IndexSet) {
        withAnimation {
            self.reminderTimes.remove(atOffsets: offsets)
        }
    }
    
    private func handleDoneButtonTap() {
        if (repeatType == .fortnightly) {
            selectedDays = [selectedDay]
        }
        
        let schedule = Schedule(
            startDate: startDate,
            endDate: endDate,
            reminderTimes: reminderTimes,
            repeatType: repeatType,
            selectedDays: selectedDays,
            selectedDates: Array(selectedDates)
        )

        medicineEditorViewModel.medicine.schedule = schedule
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ScheduleView(schedule: .init(), medicineEditorViewModel: .init())
    }
}
