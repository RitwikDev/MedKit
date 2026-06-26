//
//  MedicineEditorViewModel.swift
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

    /// Initialises the editor. Pass an existing medicine to edit, or nil to create a new one.
    init(medicine: Medicine = .init()) {
        self.medicine = medicine
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
        
        medicine.composition.sort()
    }

    func removeIngredient(at offsets: IndexSet) {
        medicine.composition.remove(atOffsets: offsets)
    }
    
    // MARK: - Schedule Management
    
    func removeSchedule() {
        medicine.schedule = nil
    }

    // MARK: - Tag Management
    
    func addTag(_ tag: Tag) {
        if !(medicine.tags.contains(tag)) {
            medicine.tags.append(tag)
            medicine.tags.sort()
        }
    }
    
    func removeTag(at offsets: IndexSet) {
        medicine.tags.remove(atOffsets: offsets)
    }
    
    // MARK: - Custom Fields
    
    func addCustomField(_ customField: CustomFieldValue) {
        medicine.customFields.append(customField)
        medicine.customFields.sort()
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
    func saveMedicine() throws {
        guard !medicine.name.isEmpty else {
            // TODO: - Add Data Validation Here...
            errorMessage = "Errors in medicine information."
            return
        }
        
        do {
            try MedicineManager.shared.save(medicine)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}
