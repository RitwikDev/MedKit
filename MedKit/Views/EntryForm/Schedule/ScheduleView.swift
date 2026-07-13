//
//  ScheduleView.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import SwiftUI

enum DateType {
    case startDate
    case endDate
}

struct ScheduleView: View {
    let schedule: Schedule
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftSchedule: Schedule
    @State private var selectedDay: Day = .sunday
    @State private var selectedDates: Set<DateComponents> = []
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    init(schedule: Schedule, medicineEditorViewModel: MedicineEditorViewModel) {
        self.schedule = schedule
        self.medicineEditorViewModel = medicineEditorViewModel
        self._draftSchedule = State(initialValue: schedule)
        
        self._selectedDay = State(initialValue: schedule.selectedDays.first ?? .sunday)
        self._selectedDates = State(initialValue: Set(schedule.selectedDates))
    }
    
    private var isDoneButtonDisabled: Bool {
        switch draftSchedule.repeatType {
        case .never:
            if ((draftSchedule.startDate != nil && draftSchedule.reminderTimes.isEmpty)
                || (draftSchedule.startDate == nil && !draftSchedule.reminderTimes.isEmpty)
            ) {
                return true
            }
        case .selectDays:
            if (draftSchedule.selectedDays.isEmpty || draftSchedule.reminderTimes.isEmpty) {
                return true
            }
        case .fortnightly:
            if (draftSchedule.reminderTimes.isEmpty) {
                return true
            }
        case .monthly, .quarterly, .biannually, .annually:
            if (draftSchedule.startDate == nil || draftSchedule.reminderTimes.isEmpty) {
                return true
            }
        case .custom:
            if (selectedDates.isEmpty || draftSchedule.reminderTimes.isEmpty) {
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
                Button("Done") {
                    handleDoneButtonTap(
                        medicineEditorViewModel: medicineEditorViewModel,
                        draftSchedule: &draftSchedule,
                        selectedDay: selectedDay,
                        selectedDates: selectedDates
                    )
                    dismiss()
                }
                .disabled(isDoneButtonDisabled)
            }
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text(toastMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .navigationTitle("Add Schedule")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var frequencyPickerSectionView: some View {
        Section("Frequency") {
            Picker("Repeat",
                   selection: $draftSchedule.repeatType.animation()
            ) {
                ForEach(RepeatType.allCases) { repeatType in
                    Text(repeatType.rawValue)
                        .tag(repeatType)
                }
            }
            .onChange(of: draftSchedule.repeatType) { _, newValue in
                selectedDay = .sunday
                
                draftSchedule.selectedDays = []
                draftSchedule.selectedDates = []
                draftSchedule.startDate = nil
                draftSchedule.endDate = nil
                draftSchedule.reminderTimes = []
            }
        }
    }
    
    @ViewBuilder
    private var conditionalSelectorSectionView: some View {
        switch draftSchedule.repeatType {
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
        Section(content: {
            ForEach(Day.allCases) { day in
                Button {
                    withAnimation {
                        toggleSelectedDay(
                            day,
                            draftSchedule: $draftSchedule,
                            selectedDay: $selectedDay,
                            showToast: $showToast,
                            toastMessage: $toastMessage
                        )
                    }
                } label: {
                    HStack {
                        Text(day.rawValue)
                        
                        if (draftSchedule.selectedDays.contains(day)) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .tint(.primary)
            }
        }, header: {
            Text("Days")
        }, footer : {
            if (draftSchedule.selectedDays.isEmpty) {
                Text("A reminder day is required.")
            }
        })
    }
    
    private var fortnightlyView: some View {
        Section("Day") {
            Picker("Remind On", selection: $selectedDay) {
                ForEach(Day.allCases) { day in
                    Text(day.rawValue)
                        .tag(day)
                }
            }
            .onChange(of: selectedDay) { _, _ in
                handleFortnightlyDayChange(
                    draftSchedule: $draftSchedule,
                    selectedDay: $selectedDay,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
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
                label: "\(draftSchedule.startDate == nil ? "Add Start Date" : "Start Date")",
                date: $draftSchedule.startDate
            )
            .onChange(of: draftSchedule.startDate) { _, newValue in
                handleDateChange(
                    to: newValue,
                    for: .startDate,
                    draftSchedule: $draftSchedule,
                    selectedDay: $selectedDay,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
            }
            
            DatePickerView(
                label: "\(draftSchedule.startDate == nil ? "Add End Date" : "End Date")",
                date: $draftSchedule.endDate
            )
            .onChange(of: draftSchedule.endDate) { _, newValue in
                handleDateChange(
                    to: newValue,
                    for: .endDate,
                    draftSchedule: $draftSchedule,
                    selectedDay: $selectedDay,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
            }
        }, header: {
            Text("Dates")
        }, footer: {
            datesSectionFooterView
        })
    }
    
    @ViewBuilder
    private var datesSectionFooterView: some View {
        if (draftSchedule.startDate == nil) {
            if (draftSchedule.repeatType == .selectDays) {
                if let earliestDay = Day.allCases.first(where: { draftSchedule.selectedDays.contains($0) }) {
                    Text("A start date is not added. Reminders will be sent every week starting \(earliestDay.rawValue).")
                }
            } else if draftSchedule.repeatType == .fortnightly {
                Text("A start date is not added. Reminders will be sent every two weeks starting \(selectedDay.rawValue).")
            } else {
                Text("A start date is required.")
            }
        }
    }
    
    private var dateSectionView: some View {
        Section("Date") {
            DatePickerView(
                label: "\(draftSchedule.startDate == nil ? "Add Date" : "Remind On")",
                date: $draftSchedule.startDate
            )
        }
    }
    
    @ViewBuilder
    private var datePickerSectionView: some View {
        switch draftSchedule.repeatType {
        case .never:
            dateSectionView
        case .custom:
            EmptyView()
        default:
            datesSectionView
        }
    }
    
    private var timePickerSectionView: some View {
        Section(content: {
            ForEach($draftSchedule.reminderTimes) { $reminderTime in
                DatePicker(
                    "Remind At",
                    selection: $reminderTime.time,
                    displayedComponents: .hourAndMinute
                )
            }
            .onDelete { indexSet in
                deleteReminderTime(at: indexSet, draftSchedule: &draftSchedule)
            }
            
            Button("Add Time") {
                onAddTime(draftSchedule: &draftSchedule)
            }
        }, header: {
            Text("Times")
        }, footer: {
            if (draftSchedule.repeatType != .never && draftSchedule.reminderTimes.isEmpty) {
                Text("A reminder time is required.")
            }
        })
    }
}

#Preview {
    NavigationStack {
        ScheduleView(schedule: .init(), medicineEditorViewModel: .init())
    }
}
