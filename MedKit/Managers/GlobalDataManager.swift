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
    
    // MARK: - Private Mapping Functions
    
    /// Translates a Core Data `MedicineEntity` into a pure Swift `Medicine` struct.
    private func mapToStruct(entity: MedicineEntity) -> Medicine {
        // 1. Map Ingredients
        let ingredientEntities = entity.composition as? Set<IngredientEntity> ?? []
        let ingredients = ingredientEntities.map {
            Ingredient(
                id: $0.id ?? UUID(),
                name: $0.name ?? "",
                strengthAmount: $0.strengthAmount > 0 ? $0.strengthAmount : nil,
                strengthUnit: $0.strengthUnit
            )
        }
        
        // 2. Map Tags
        let tagEntities = entity.tags as? Set<TagEntity> ?? []
        let tags = tagEntities.map { Tag(id: $0.id ?? UUID(), value: $0.value ?? "") }
        
        // 3. Map Custom Fields
        let customFieldEntities = entity.customFields as? Set<CustomFieldValueEntity> ?? []
        let customFields = customFieldEntities.map { cfEntity in
            var decodedList: [String]? = nil
            if let data = cfEntity.textListValueData, let list = try? JSONDecoder().decode([String].self, from: data) {
                decodedList = list
            }
            
            var documentValues: [Document] = []
            if let documentEntities = cfEntity.documents as? Set<DocumentEntity> {
                documentEntities.forEach {
                    documentValues.append(
                        Document(
                            id: $0.id ?? UUID(),
                            name: $0.name ?? "Unknown Document",
                            documentExtension: $0.documentExtension ?? "Unknown",
                            documentData: $0.documentData ?? Data(),
                            documentType: DocumentType(rawValue: $0.type ?? "document") ?? .document
                        )
                    )
                }
            }
            
            let defEntity = cfEntity.definition
            let definition = CustomField(
                id: defEntity?.id ?? UUID(),
                label: defEntity?.label ?? "",
                dataType: CustomFieldDataType(rawValue: defEntity?.dataType ?? "") ?? .text
            )
            
            return CustomFieldValue(
                id: cfEntity.id ?? UUID(),
                textValue: cfEntity.textValue,
                dateValue: cfEntity.dateValue,
                textListValue: decodedList?.sorted(),
                documentValue: documentValues.isEmpty ? nil : documentValues.sorted(),
                definition: definition
            )
        }
        
        // 4. Map Schedule
        var scheduleStruct: Schedule? = nil
        if let scheduleEntity = entity.schedule {
            
            // Decode complex binary date components
            var mappedDates: [DateComponents] = []
            if let datesData = scheduleEntity.selectedDatesData,
               let decoded = try? JSONDecoder().decode([DateComponents].self, from: datesData) {
                mappedDates = decoded
            }
            
            // Extract transformable string array and map back to enums
            let rawDays = scheduleEntity.selectedDays ?? []
            let mappedDays = rawDays.compactMap { Day(rawValue: $0 as? String ?? "Unknown") }
            
            // Map Reminders
            let reminderEntities = scheduleEntity.reminderTimes as? Set<ReminderTimeEntity> ?? []
            let mappedReminders = reminderEntities.map { ReminderTime(id: $0.id ?? UUID(), time: $0.time ?? Date()) }
            
            scheduleStruct = Schedule(
                id: scheduleEntity.id ?? UUID(),
                startDate: scheduleEntity.startDate,
                endDate: scheduleEntity.endDate,
                reminderTimes: mappedReminders,
                repeatType: RepeatType(rawValue: scheduleEntity.repeatType ?? "") ?? .never,
                selectedDays: mappedDays,
                selectedDates: mappedDates
            )
        }
        
        // 5. Construct Final Medicine Struct
        return Medicine(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            quantity: entity.quantity,
            manufacturedDate: entity.manufacturedDate,
            expiryDate: entity.expiryDate,
            strengthAmount: entity.strengthAmount > 0 ? entity.strengthAmount : nil,
            strengthUnit: entity.strengthUnit,
            composition: ingredients,
            schedule: scheduleStruct,
            tags: tags,
            customFields: customFields
        )
    }
}
