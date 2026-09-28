//
//  DosageView.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import SwiftUI

enum DateType {
    case startDate
    case endDate
}

struct DosageView: View {
    let dosage: DosageModel
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var draftDosage: DosageModel
    @State private var draftDoseQuantityString: String = ""
    @State private var selectedDay: Day = .sunday
    @State private var selectedDates: Set<DateComponents> = []
    
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    
    private var sanitisedDates: Binding<Set<DateComponents>> {
        Binding(
            get: { self.selectedDates },
            set: { newValue in
                // 2. Rebuild the set with strictly uniform components
                var cleanedSet: Set<DateComponents> = []
                
                for component in newValue {
                    // Keep only what is strictly necessary for equality matching
                    var cleanComponent = DateComponents()
                    cleanComponent.year = component.year
                    cleanComponent.month = component.month
                    cleanComponent.day = component.day
                    
                    // Explicitly lock the calendar to prevent hidden mismatches
                    cleanComponent.calendar = Calendar.current
                    
                    cleanedSet.insert(cleanComponent)
                }
                
                // 3. Assign the mathematically pure set back to your state
                withAnimation {
                    self.selectedDates = cleanedSet
                }
            }
        )
    }
    
    init(dosage: DosageModel, medicineEditorViewModel: MedicineEditorViewModel) {
        self.dosage = dosage
        self.medicineEditorViewModel = medicineEditorViewModel
        self._draftDosage = State(initialValue: dosage)
        
        let doseQuantity = dosage.dosageQuantity == nil ? "" : String(dosage.dosageQuantity ?? 0)
        self._draftDoseQuantityString = State(initialValue: doseQuantity)
        self._selectedDay = State(initialValue: dosage.selectedDays.first ?? .sunday)
        self._selectedDates = State(initialValue: Set(dosage.selectedDates))
    }
    
    private var isDoneButtonDisabled: Bool {
        if (draftDosage.repeatType != .never && (draftDosage.dosageQuantity ?? 0).isZero) {
            return true
        }

        switch draftDosage.repeatType {
        case .never:
            if ((draftDosage.startDate != nil && draftDosage.reminderTimes.isEmpty)
                || (draftDosage.startDate == nil && !draftDosage.reminderTimes.isEmpty)
            ) {
                return true
            }
        case .selectDays:
            if (draftDosage.selectedDays.isEmpty || draftDosage.startDate == nil || draftDosage.reminderTimes.isEmpty) {
                return true
            }
        case .fortnightly, .monthly, .quarterly, .biannually, .annually:
            if (draftDosage.startDate == nil || draftDosage.reminderTimes.isEmpty) {
                return true
            }
        case .custom:
            if (selectedDates.isEmpty || draftDosage.reminderTimes.isEmpty) {
                return true
            }
        }
        
        return false
    }
    
    var body: some View {
        Form {
            doseSectionView
            frequencyPickerSectionView
            conditionalSelectorSectionView
            datePickerSectionView
            timePickerSectionView
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    handleDoneButtonTap(
                        medicineEditorViewModel: medicineEditorViewModel,
                        draftDosage: &draftDosage,
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
                ToastView(toastMessage: toastMessage)
            }
        }
        .navigationTitle("Add Dosage")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var doseSectionView: some View {
        Section(
            content: {
                TextField("Quantity", text: $draftDoseQuantityString)
                    .keyboardType(.decimalPad)
                    .onChange(of: draftDoseQuantityString) { oldValue, newValue in
                        if newValue.trimmedIsEmpty {
                            draftDosage.dosageQuantity = nil
                            return
                        }
                        
                        let floatValue = Float(newValue)
                        if (floatValue == nil || (floatValue ?? -1) < 0) {
                            draftDoseQuantityString = oldValue
                        } else {
                            draftDosage.dosageQuantity = floatValue ?? 0
                        }
                    }
            }, header: {
                Text("Dose Quantity")
            }, footer: {
                VStack(alignment: .leading) {
                    if let unit = medicineEditorViewModel.medicine.stock?.unit {
                        Text(unit)
                    }
                }
            }
        )
    }
    
    private var frequencyPickerSectionView: some View {
        Section("Frequency") {
            Picker("Repeat",
                   selection: $draftDosage.repeatType.animation()
            ) {
                ForEach(RepeatType.allCases) { repeatType in
                    Text(repeatType.localizedName)
                        .tag(repeatType)
                }
            }
            .onChange(of: draftDosage.repeatType) { _, newValue in
                selectedDay = .sunday
                selectedDates = []
                
                draftDosage.selectedDays = []
                draftDosage.selectedDates = []
                draftDosage.startDate = nil
                draftDosage.endDate = nil
                draftDosage.reminderTimes = []
                
                if (newValue == .never) {
                    draftDoseQuantityString = ""
                }
            }
        }
    }
    
    @ViewBuilder
    private var conditionalSelectorSectionView: some View {
        switch draftDosage.repeatType {
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
                            draftDosage: $draftDosage,
                            selectedDay: $selectedDay,
                            showToast: $showToast,
                            toastMessage: $toastMessage
                        )
                    }
                } label: {
                    HStack {
                        Text(day.localizedName)
                        
                        if (draftDosage.selectedDays.contains(day)) {
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
            if (draftDosage.selectedDays.isEmpty) {
                Text("Please select a reminder day.")
            }
        })
    }
    
    private var fortnightlyView: some View {
        Section("Day") {
            Picker("Remind On", selection: $selectedDay) {
                ForEach(Day.allCases) { day in
                    Text(day.localizedName)
                        .tag(day)
                }
            }
            .onChange(of: selectedDay) { _, _ in
                handleFortnightlyDayChange(
                    draftDosage: $draftDosage,
                    selectedDay: $selectedDay,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
            }
        }
    }
    
    private var customView: some View {
        Section(content: {
            MultiDatePicker("Select Dates", selection: sanitisedDates.animation())
        }, header: {
            Text("Dates")
        }, footer: {
            if (selectedDates.isEmpty) {
                Text("Please select at least one date.")
            }
        })
    }
    
    private var datesSectionView: some View {
        Section(content: {
            DatePickerView(
                label: "\(draftDosage.startDate == nil ? "Add Start Date" : "Start Date")",
                date: $draftDosage.startDate
            )
            .onChange(of: draftDosage.startDate) { _, newValue in
                handleDateChange(
                    to: newValue,
                    for: .startDate,
                    draftDosage: $draftDosage,
                    selectedDay: $selectedDay,
                    showToast: $showToast,
                    toastMessage: $toastMessage
                )
            }
            
            DatePickerView(
                label: "\(draftDosage.startDate == nil ? "Add End Date" : "End Date")",
                date: $draftDosage.endDate
            )
            .onChange(of: draftDosage.endDate) { _, newValue in
                handleDateChange(
                    to: newValue,
                    for: .endDate,
                    draftDosage: $draftDosage,
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
        if (draftDosage.startDate == nil) {
            Text("Please select a start date.")
        }
    }
    
    private var dateSectionView: some View {
        Section("Date") {
            DatePickerView(
                label: "\(draftDosage.startDate == nil ? "Add Date" : "Remind On")",
                date: $draftDosage.startDate
            )
        }
    }
    
    @ViewBuilder
    private var datePickerSectionView: some View {
        switch draftDosage.repeatType {
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
            ForEach($draftDosage.reminderTimes) { $reminderTime in
                DatePicker(
                    "Remind At",
                    selection: $reminderTime.time,
                    displayedComponents: .hourAndMinute
                )
            }
            .onDelete { indexSet in
                deleteReminderTime(at: indexSet, draftDosage: &draftDosage)
            }
            
            if (draftDosage.reminderTimes.count < 5) {
                Button("Add Time") {
                    onAddTime(draftDosage: &draftDosage)
                }
            }
        }, header: {
            Text("Times")
        }, footer: {
            if (draftDosage.repeatType != .never && draftDosage.reminderTimes.isEmpty) {
                Text("Please add a reminder time.")
            }
        })
    }
}

#Preview {
    NavigationStack {
        DosageView(dosage: .init(repeatType: .custom), medicineEditorViewModel: .init())
    }
}
