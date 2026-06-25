//
//  Playground.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation
import SwiftData

enum DatabaseTypeEnum {
    case all, medicines, ingredients, tags, customFields
}

@MainActor
func deleteAllData(from context: ModelContext, of type: DatabaseTypeEnum = .all) {
    print("Initiating complete database wipe...")
    
    do {
        // Run batch deletes on concrete types so the #Predicate macro can resolve them perfectly
        /*
        if (type == .all || type == .medicines) {
            try context.delete(model: MedicineModel.self, where: #Predicate<MedicineModel> { _ in true })
        }
        
        if (type == .all || type == .ingredients) {
            // TODO: This delete operation is throwing an error
            try context.delete(model: IngredientModel.self, where: #Predicate<IngredientModel> { _ in true })
        }
        
        if (type == .all || type == .tags) {
            try context.delete(model: TagModel.self, where: #Predicate<TagModel> { _ in true })
        }
        
        if (type == .all || type == .customFields) {
            try context.delete(model: CustomFieldModel.self, where: #Predicate<CustomFieldModel> { _ in true })
        }
        */
        
        // Push the changes instantly to the underlying SQLite database file
        try context.save()
        print("Database cleared successfully.")
        
    } catch {
        print("Failed to clear database of type \(type): \(error.localizedDescription)")
    }
}
