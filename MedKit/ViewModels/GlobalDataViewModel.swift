//
//  GlobalDataViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 22/06/26.
//

import SwiftUI

@Observable
class GlobalDataViewModel {
    var allTags: [Tag] = []
    var allIngredients: [Ingredient] = []
    var allCustomFields: [CustomField] = []
    var allStrengthUnits: Set<String> = []
    var allStockTypes: Set<String> = []
    var errorMessage: String?
    
    init() {
        fetchAllData()
    }
    
    func fetchAllData() {
        fetchAllTags()
        fetchAllIngredients()
        fetchAllCustomFields()
        fetchAllStrengthUnits()
        fetchAllStockTypes()
    }
    
    // MARK: - Fetch All Functions
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllTags() {
        do {
            self.allTags = try GlobalDataManager.shared.fetchAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllIngredients() {
        do {
            self.allIngredients = try GlobalDataManager.shared.fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllCustomFields() {
        do {
            self.allCustomFields = try GlobalDataManager.shared.fetchAllCustomFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllStrengthUnits() {
        do {
            self.allStrengthUnits = try GlobalDataManager.shared.fetchAllStrengthUnits()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllStockTypes() {
        do {
            self.allStockTypes = try GlobalDataManager.shared.fetchAllStockTypes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete Record at IndexSet Functions
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    func deleteTag(at offsets: IndexSet) {
        do {
            for index in offsets {
                let tagId = allTags[index].id
                try GlobalDataManager.shared.deleteTag(id: tagId)
            }
            fetchAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    func deleteIngredient(at offsets: IndexSet) {
        do {
            for index in offsets {
                let ingredientId = allIngredients[index].id
                try GlobalDataManager.shared.deleteIngredient(id: ingredientId)
            }
            fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    func deleteCustomField(at offsets: IndexSet) {
        do {
            for index in offsets {
                let customFieldId = allCustomFields[index].id
                try GlobalDataManager.shared.deleteCustomField(id: customFieldId)
            }
            fetchAllCustomFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete All Functions
    
    /// Asks the Manager to delete all tags.
    func deleteAllTags() {
        do {
            try GlobalDataManager.shared.deleteAllTags()
            fetchAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to delete all ingredients.
    func deleteAllIngredients() {
        do {
            try GlobalDataManager.shared.deleteAllIngredients()
            fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the manager to delete all custom fields.
    func deleteAllCustomFields() {
        do {
            try GlobalDataManager.shared.deleteAllCustomFields()
            fetchAllCustomFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
