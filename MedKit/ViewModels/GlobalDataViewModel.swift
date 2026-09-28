//
//  GlobalDataViewModel.swift
//  MedKit
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
    
    private let manager: GlobalDataManagerProtocol
    
    init(manager: GlobalDataManagerProtocol = GlobalDataManager.shared) {
        self.manager = manager
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
    
    func fetchAllTags() {
        do {
            let tags = try manager.fetchAllTags()
            self.allTags = Array(Set(tags)).sorted()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllIngredients() {
        do {
            self.allIngredients = try manager.fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllCustomFields() {
        do {
            let customFields = try manager.fetchAllCustomFields()
            self.allCustomFields = Array(Set(customFields)).sorted { $0.label < $1.label }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllStrengthUnits() {
        do {
            self.allStrengthUnits = try manager.fetchAllStrengthUnits()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllStockTypes() {
        do {
            self.allStockTypes = try manager.fetchAllStockTypes()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete Record at IndexSet Functions
    
    func deleteTag(at offsets: IndexSet) {
        do {
            for index in offsets {
                let tagId = allTags[index].id
                try manager.deleteTag(id: tagId)
            }
            fetchAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteIngredient(at offsets: IndexSet) {
        do {
            for index in offsets {
                let ingredientId = allIngredients[index].id
                try manager.deleteIngredient(id: ingredientId)
            }
            fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteCustomField(at offsets: IndexSet) {
        do {
            for index in offsets {
                let customFieldId = allCustomFields[index].id
                try manager.deleteCustomField(id: customFieldId)
            }
            fetchAllCustomFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Delete All Functions
    
    func deleteAllTags() {
        do {
            try manager.deleteAllTags()
            fetchAllTags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAllIngredients() {
        do {
            try manager.deleteAllIngredients()
            fetchAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAllCustomFields() {
        do {
            try manager.deleteAllCustomFields()
            fetchAllCustomFields()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
