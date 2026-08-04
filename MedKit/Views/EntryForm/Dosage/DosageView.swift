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
        if ((draftDosage.dosageQuantity ?? 0).isZero) {
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
                    Text(repeatType.rawValue)
                        .tag(repeatType)
                }
            }
            .onChange(of: draftDosage.repeatType) { _, newValue in
                selectedDay = .sunday
                
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
                        Text(day.rawValue)
                        
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
                    draftDosage: $draftDosage,
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
            Text("A start date is required.")
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
                Text("A reminder time is required.")
            }
        })
    }
}

#Preview {
    NavigationStack {
        DosageView(dosage: .init(), medicineEditorViewModel: .init())
    }
}
