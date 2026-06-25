//
//  MedicineViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import SwiftUI

/// Powers the medicine creation and editing form.
/// Acts as a temporary scratchpad until the user taps "Save".
@Observable
class MedicineEditorViewModel {
    
    /// The temporary draft being edited on screen.
    var medicine: Medicine
    var errorMessage: String?

    /// Initialiwes the editor. Pass an existing medicine to edit, or nil to create a new one.
    init(medicine: Medicine = .init()) {
        self.medicine = medicine
    }

    // MARK: - Basic Info
    
    func updateName(_ name: String) {
        medicine.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func updateStrength(amount: Float?, unit: String?) {
        medicine.strengthAmount = amount
        medicine.strengthUnit = unit?.trimmingCharacters(in: .whitespacesAndNewlines)
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
        for ingredient in composition {
            // Replaced equalsName with direct name comparison based on the struct properties
            if let index = medicine.composition.firstIndex(where: { $0.name == ingredient.name }) {
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
    
    // MARK: - Schedule Management
    
    func removeSchedule() {
        medicine.schedule = nil
    }

    // MARK: - Tag Management
    
    func addTag(_ tag: Tag) {
        let trimmedValue = tag.value.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    // MARK: - Custom Fields
    
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
    
    // MARK: - Database Handoff
    
    /// Validates the draft and hands the finalised pure struct to the Manager for database persistence.
    func saveToDatabase() {
        guard !medicine.name.isEmpty else {
            errorMessage = "Name cannot be empty"
            return
        }
        
        do {
            try MedicineManager.shared.save(medicine)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
