//
//  MedicineViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//


import Foundation
import Observation

@Observable
class MedicineViewModel {
    // The source of truth for the form/view
    var medicine: Medicine

    init(medicine: Medicine = .init()) {
        self.medicine = medicine
    }
    
    func getMedicineFromCodableMedicineModel(cMedicineModel: CodableMedicineModel) {
        self.medicine = Medicine(
            name: cMedicineModel.name,
            manufacturedDate: cMedicineModel.manufacturedDate,
            expiryDate: cMedicineModel.expiryDate,
            strengthAmount: cMedicineModel.strengthAmount,
            strengthUnit: cMedicineModel.strengthUnit,
            composition: cMedicineModel.composition.map { Ingredient(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit) },
        )
    }

    // MARK: - Basic Info
    func updateName(_ name: String) {
        medicine.name = name.trimmed
    }

    func updateStrength(amount: Float?, unit: String?) {
        medicine.strengthAmount = amount
        medicine.strengthUnit = unit?.trimmed
    }

    func updateQuantity(_ quantity: Float) {
        medicine.quantity = quantity
    }

    // MARK: - Ingredient Management
    func upsertIngredient(_ ingredient: Ingredient) {
        if let index = medicine.composition.firstIndex(where: { $0.id == ingredient.id }) {
            // Update existing
            medicine.composition[index] = ingredient
        } else {
            // Add new
            medicine.composition.append(ingredient)
        }
    }
    
    func addComposition(_ composition: [Ingredient]) {
        for (index, ingredient) in composition.enumerated() {
            let isPresent = medicine.composition.contains(where: { $0.equalsName(ingredient) })
            if (isPresent) {
                medicine.composition.remove(at: index)
            }
            
            medicine.composition.append(ingredient)
        }
    }

    func removeIngredient(at offsets: IndexSet) {
        medicine.composition.remove(atOffsets: offsets)
    }

    func removeIngredient(_ ingredient: Ingredient) {
        medicine.composition.removeAll { $0.id == ingredient.id }
    }
    
    func removeSchedule() {
        medicine.schedule = nil
    }

    // MARK: - Tag Management
    func addTag(_ tag: Tag) {
        let trimmedValue = tag.value.trimmed
        guard !trimmedValue.isEmpty else { return }
        
        // Prevent duplicates in the UI state
        if !medicine.tags.contains(where: { $0.value.lowercased() == trimmedValue.lowercased() }) {
            var newTag = tag
            newTag.value = trimmedValue
            medicine.tags.append(newTag)
        }
    }

    func removeTag(_ tag: Tag) {
        medicine.tags.removeAll { $0.id == tag.id }
    }
    
    func removeTags(at offsets: IndexSet) {
        medicine.tags.remove(atOffsets: offsets)
    }

    // MARK: - Dates
    func updateDates(manufactured: Date?, expiry: Date?) {
        medicine.manufacturedDate = manufactured
        medicine.expiryDate = expiry
    }
    
    // MARK: - Custom fields
    func addCustomField(_ customField: CustomFieldValue) {
        medicine.customFields.append(customField)
    }
    
    func addCustomListItem(to customField: CustomFieldValue, value: String) {
        guard let fieldIndex = medicine.customFields.firstIndex(where: { $0.id == customField.id }) else {
            return
        }
        
        var updatedList = medicine.customFields[fieldIndex].listValue ?? []
        updatedList.append(value)
        
        medicine.customFields[fieldIndex].listValue = updatedList
    }
    
    func deleteCustomListItem(from customField: CustomFieldValue, at indexSet: IndexSet) {
        guard let fieldIndex = medicine.customFields.firstIndex(where: { $0.id == customField.id }) else {
            return
        }
        
        var updatedList = medicine.customFields[fieldIndex].listValue ?? []
        updatedList.remove(atOffsets: indexSet)
        
        medicine.customFields[fieldIndex].listValue = updatedList
    }
}
