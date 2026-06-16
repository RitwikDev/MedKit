//
//  PreviewData.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//


import Foundation
import SwiftData
import SwiftUI

@MainActor
public struct PreviewData {
    
    // MARK: - 1. SwiftData Models (For @Query)
    static let medicineModels: [MedicineModel] = {
        let manufacturerField = CustomFieldModel(label: "Manufacturer", dataType: .text)
        let sideEffectsField = CustomFieldModel(label: "Side Effects", dataType: .list)
        let openedDateField = CustomFieldModel(label: "Date Opened", dataType: .date)
        
        return [
            // 1. Basic Painkiller
            MedicineModel(
                name: "Paracetamol", quantity: 50, expiryDate: Calendar.current.date(byAdding: .year, value: 1, to: .now), strengthAmount: 500, strengthUnit: "mg",
                composition: [CompositionModel(name: "Acetaminophen", strengthAmount: 500, strengthUnit: "mg")],
                schedule: ScheduleModel(startDate: .now, reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Pain Relief"), TagModel(value: "Fever")],
                customFields: [
                    CustomFieldValueModel(textValue: "Johnson & Johnson", definition: manufacturerField),
                    CustomFieldValueModel(textListValue: ["Nausea", "Dizziness"], definition: sideEffectsField),
                ]
            ),
            
            // 2. Antibiotic
            MedicineModel(
                name: "Amoxicillin", quantity: 21, expiryDate: Calendar.current.date(byAdding: .month, value: 6, to: .now), strengthAmount: 250, strengthUnit: "mg",
                composition: [CompositionModel(name: "Amoxicillin trihydrate", strengthAmount: 250, strengthUnit: "mg")],
                schedule: ScheduleModel(startDate: .now, endDate: Calendar.current.date(byAdding: .day, value: 7, to: .now), reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Antibiotic"), TagModel(value: "Prescription")],
                customFields: [CustomFieldValueModel(textListValue: ["Nausea", "Dizziness"], definition: sideEffectsField)]
            ),
            
            // 3. Daily Vitamin
            MedicineModel(
                name: "Multivitamin Plus", quantity: 120,
                composition: [CompositionModel(name: "Vitamin C", strengthAmount: 100, strengthUnit: "mg"), CompositionModel(name: "Vitamin D3", strengthAmount: 1000, strengthUnit: "IU")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Supplement"), TagModel(value: "Morning")],
                customFields: [CustomFieldValueModel(dateValue: Calendar.current.date(byAdding: .day, value: -10, to: .now), definition: openedDateField)]
            ),
            
            // 4. Allergy Medication (As needed)
            MedicineModel(
                name: "Cetirizine", quantity: 30, strengthAmount: 10, strengthUnit: "mg",
                composition: [CompositionModel(name: "Cetirizine Hydrochloride", strengthAmount: 10, strengthUnit: "mg")],
                tags: [TagModel(value: "Allergy"), TagModel(value: "Antihistamine")]
            ),
            
            // 5. Weekly Injection
            MedicineModel(
                name: "Ozempic", quantity: 4, strengthAmount: 2, strengthUnit: "mg/1.5mL",
                composition: [CompositionModel(name: "Semaglutide", strengthAmount: 2, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .weekly, selectedDay: .sunday),
                tags: [TagModel(value: "Diabetes"), TagModel(value: "Injection")]
            ),
            
            // 6. Blood Pressure
            MedicineModel(
                name: "Lisinopril", quantity: 90, strengthAmount: 10, strengthUnit: "mg",
                composition: [CompositionModel(name: "Lisinopril", strengthAmount: 10, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Heart"), TagModel(value: "Blood Pressure")]
            ),
            
            // 7. Cholesterol
            MedicineModel(
                name: "Atorvastatin", quantity: 60, strengthAmount: 40, strengthUnit: "mg",
                composition: [CompositionModel(name: "Atorvastatin Calcium", strengthAmount: 40, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Cholesterol")]
            ),
            
            // 8. Asthma Inhaler
            MedicineModel(
                name: "Albuterol Inhaler", quantity: 200, strengthAmount: 90, strengthUnit: "mcg/actuation",
                composition: [CompositionModel(name: "Albuterol Sulfate", strengthAmount: 90, strengthUnit: "mcg")],
                tags: [TagModel(value: "Asthma"), TagModel(value: "Rescue Inhaler")],
                customFields: [CustomFieldValueModel(dateValue: .now, definition: openedDateField)]
            ),
            
            // 9. Bi-annual Treatment
            MedicineModel(
                name: "Prolia", quantity: 1, strengthAmount: 60, strengthUnit: "mg",
                composition: [CompositionModel(name: "Denosumab", strengthAmount: 60, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .biannually),
                tags: [TagModel(value: "Bone Health")]
            ),
            
            // 10. Migraine Medication
            MedicineModel(
                name: "Sumatriptan", quantity: 9, strengthAmount: 50, strengthUnit: "mg",
                composition: [CompositionModel(name: "Sumatriptan Succinate", strengthAmount: 50, strengthUnit: "mg")],
                tags: [TagModel(value: "Migraine"), TagModel(value: "As Needed")]
            ),
            
            // 11. Acid Reflux
            MedicineModel(
                name: "Omeprazole", quantity: 42, strengthAmount: 20, strengthUnit: "mg",
                composition: [CompositionModel(name: "Omeprazole", strengthAmount: 20, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Stomach")]
            ),
            
            // 12. Thyroid Medication
            MedicineModel(
                name: "Levothyroxine", quantity: 30, strengthAmount: 50, strengthUnit: "mcg",
                composition: [CompositionModel(name: "Levothyroxine Sodium", strengthAmount: 50, strengthUnit: "mcg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Thyroid")]
            ),
            
            // 13. Sleep Aid
            MedicineModel(
                name: "Melatonin", quantity: 100, strengthAmount: 5, strengthUnit: "mg",
                composition: [CompositionModel(name: "Melatonin", strengthAmount: 5, strengthUnit: "mg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .daily),
                tags: [TagModel(value: "Sleep")]
            ),
            
            // 14. Monthly Preventative
            MedicineModel(
                name: "Heartworm Preventative", quantity: 6,
                composition: [CompositionModel(name: "Ivermectin", strengthAmount: 68, strengthUnit: "mcg")],
                schedule: ScheduleModel(reminderTimes: [ReminderTime(time: .now)], repeatType: .monthly),
                tags: [TagModel(value: "Pet")]
            ),
            
            // 15. Empty Draft
            MedicineModel()
        ]
    }()

    // MARK: - 2. In-Memory SwiftData Container
    public static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            // Register all your models
            let container = try ModelContainer(for: MedicineModel.self, CustomFieldModel.self, TagModel.self, configurations: config)
            let context = container.mainContext
            
            // Insert mock data into the context
            for medicine in medicineModels {
                context.insert(medicine)
            }
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }()
    
    // MARK: - 3. ViewModels (For Detail/Form Views)
    static var medicineViewModels: [MedicineViewModel] {
        medicineModels.map { model in
            
            // Map Tags
            let tags = model.tags.map { Tag(persistentIdentifier: $0.persistentModelID, value: $0.value) }
            // Map Compositions (Using your existing Composition(from:) extension)
            let comps = model.composition.map { Composition(from: $0) }
            // Map Custom Fields (Using your existing CustomFieldValue(from:) extension)
            let fields = model.customFields.map { CustomFieldValue(from: $0) }
            
            // Map Schedule safely
            var scheduleStruct: Schedule? = nil
            if let schedModel = model.schedule {
                scheduleStruct = Schedule(
                    startDate: schedModel.startDate, endDate: schedModel.endDate,
                    reminderTimes: schedModel.reminderTimes, repeatType: schedModel.repeatType,
                    selectedDay: schedModel.selectedDay, selectedDates: schedModel.selectedDates
                )
            }
            
            // Assemble the final struct
            let structMed = Medicine(
                persistentIdentifier: model.persistentModelID, // Links it to the SwiftData record
                name: model.name,
                quantity: model.quantity,
                manufacturedDate: model.manufacturedDate,
                expiryDate: model.expiryDate,
                strengthAmount: model.strengthAmount,
                strengthUnit: model.strengthUnit,
                composition: comps,
                schedule: scheduleStruct,
                tags: tags,
                customFields: fields
            )
            
            return MedicineViewModel(medicine: structMed)
        }
    }
}
