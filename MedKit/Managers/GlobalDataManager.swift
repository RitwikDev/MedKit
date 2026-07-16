//
//  GlobalDataManager.swift
//  MedKit
//
//  Created by Rishik Dev on 23/06/26.
//

import CoreData
import Foundation

class GlobalDataManager {
    /// The shared singleton instance.
    static let shared = GlobalDataManager()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetch All Functions
    
    /// Fetches all tags from the database and translates them into pure Swift structs.
    /// - Returns: An array of `Tag` structs sorted alphabetically by value.
    func fetchAllTags() throws -> [Tag] {
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TagEntity.value, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map {
                Tag(
                    id: $0.id ?? UUID(),
                    value: $0.value ?? "Unknown Tag"
                )
            }
        } catch {
            throw error
        }
    }
    
    /// Fetches all ingredients from the database and translates them into pure Swift structs.
    /// - Returns: An array of `Ingredient` structs sorted alphabetically by name.
    func fetchAllIngredients() throws -> [Ingredient] {
        let request: NSFetchRequest<IngredientEntity> = IngredientEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IngredientEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map {
                Ingredient(
                    id: $0.id ?? UUID(),
                    name: $0.name ?? "Unknown Ingredient",
                    strengthAmount: $0.strengthAmount,
                    strengthUnit: $0.strengthUnit
                )
            }
        } catch {
            throw error
        }
    }
    
    /// Fetches all custom fields from the database and translates them into pure Swift structs.
    /// - Returns: An array of `CustomField` structs sorted alphabetically by label.
    func fetchAllCustomFields() throws -> [CustomField] {
        let request: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomFieldEntity.label, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map {
                CustomField(
                    id: $0.id ?? UUID(),
                    label: $0.label ?? "Unknown Custom Field",
                    dataType: CustomFieldDataType(rawValue: $0.dataType ?? "") ?? .text
                )
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Delete Record by UUID Functions
    
    /// Deletes a tag record by its UUID.
    /// - Parameter id: The unique identifier of the tag to delete.
    func deleteTag(id: UUID) throws {
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes an ingredient record by its UUID.
    /// - Parameter id: The unique identifier of the ingredient to delete.
    func deleteIngredient(id: UUID) throws {
        let request: NSFetchRequest<IngredientEntity> = IngredientEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes a tag record by its UUID.
    /// - Parameter id: The unique identifier of the tag to delete.
    func deleteCustomField(id: UUID) throws {
        let request: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Delete All Functions
    
    /// Deletes all medicines from the database, ensuring CloudKit syncs the deletions.
    func deleteAllMedicines() throws {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        
        // We only need the objects to delete them, we do not need their properties
        request.includesPropertyValues = false
        
        do {
            let allMedicines = try context.fetch(request)
            for medicine in allMedicines {
                context.delete(medicine)
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes all tags from the database, ensuring CloudKit syncs the deletions.
    func deleteAllTags() throws {
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        
        // We only need the objects to delete them, we do not need their properties
        request.includesPropertyValues = false
        
        do {
            let allTags = try context.fetch(request)
            for tag in allTags {
                context.delete(tag)
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes all ingredients from the database, ensuring CloudKit syncs the deletions.
    func deleteAllIngredients() throws {
        let request: NSFetchRequest<IngredientEntity> = IngredientEntity.fetchRequest()
        
        // We only need the objects to delete them, we do not need their properties
        request.includesPropertyValues = false
        
        do {
            let allIngredients = try context.fetch(request)
            for ingredient in allIngredients {
                context.delete(ingredient)
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    /// Deletes all custom fields from the database, ensuring CloudKit syncs the deletions.
    func deleteAllCustomFields() throws {
        let request: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
        
        // We only need the objects to delete them, we do not need their properties
        request.includesPropertyValues = false
        
        do {
            let allCustomFields = try context.fetch(request)
            for customField in allCustomFields {
                context.delete(customField)
            }
            
            if context.hasChanges {
                try context.save()
            }
        } catch {
            throw error
        }
    }
}
