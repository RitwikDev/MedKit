//
//  MedicineManager.swift
//  MedKit
//
//  Created by Rishik Dev on 19/06/26.
//

import CloudKit
import CoreData
import Foundation

/// A singleton manager responsible for all database transactions.
/// It translates pure Swift structs into Core Data entities and vice versa,
/// ensuring the UI and ViewModels remain completely decoupled from the database framework.
class MedicineManager {
    
    /// The shared singleton instance.
    static let shared = MedicineManager()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetching
    
    /// Fetches all medicines from the database and translates them into pure Swift structs.
    /// - Returns: An array of `Medicine` structs sorted alphabetically by name.
    func fetchAllMedicines() throws -> [Medicine] {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { mapToStruct(entity: $0) }
        } catch {
            throw error
        }
    }
    
    // MARK: - Saving & Deleting
    
    /// Saves a pure `Medicine` struct to the database (Upsert pattern).
    /// - Parameter medicine: The finalised draft struct to save.
    func save(_ medicine: Medicine) throws {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicine.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            let entity = results.first ?? MedicineEntity(context: context)
            
            // 1. Map Basic Attributes
            entity.id = medicine.id
            entity.name = medicine.name
            entity.quantity = medicine.quantity
            entity.manufacturedDate = medicine.manufacturedDate
            entity.expiryDate = medicine.expiryDate
            entity.strengthAmount = medicine.strengthAmount ?? 0
            entity.strengthUnit = medicine.strengthUnit
            
            // 2. Map Ingredients (One-to-Many Owned)
            // Delete existing to prevent orphans, then rebuild
            if let existingIngredients = entity.composition as? Set<IngredientEntity> {
                existingIngredients.forEach { context.delete($0) }
            }
            
            for structIngredient in medicine.composition {
                let ingredientEntity = IngredientEntity(context: context)
                ingredientEntity.id = structIngredient.id
                ingredientEntity.name = structIngredient.name
                ingredientEntity.strengthAmount = structIngredient.strengthAmount ?? 0
                ingredientEntity.strengthUnit = structIngredient.strengthUnit
                ingredientEntity.medicine = entity
            }
            
            // 3. Map Tags (Many-to-Many Shared)
            // We do NOT delete TagEntities here because they might be shared with other medicines.
            // We only reset the relationship links for this specific medicine.
            var linkedTags = Set<TagEntity>()
            for structTag in medicine.tags {
                let tagReq: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                tagReq.predicate = NSPredicate(format: "id == %@", structTag.id as CVarArg)
                
                if let existingTag = try context.fetch(tagReq).first {
                    // Link existing global tag
                    linkedTags.insert(existingTag)
                } else {
                    // Create new global tag and link it
                    let newTag = TagEntity(context: context)
                    newTag.id = structTag.id
                    newTag.value = structTag.value
                    linkedTags.insert(newTag)
                }
            }
            entity.tags = linkedTags as NSSet
            
            // 4. Map Custom Fields (One-to-Many Owned Values, Linked to Global Definitions)
            // Delete existing values to prevent orphans, then rebuild based on the current draft.
            if let existingCustomFields = entity.customFields as? Set<CustomFieldValueEntity> {
                existingCustomFields.forEach { context.delete($0) }
            }
            
            for structCF in medicine.customFields {
                let cfEntity = CustomFieldValueEntity(context: context)
                cfEntity.id = structCF.id
                cfEntity.medicine = entity
                
                // Step 2: Store only the provided value based on the data type.
                // Whichever properties are not assigned here will naturally default to nil in Core Data.
                cfEntity.textValue = structCF.textValue
                cfEntity.dateValue = structCF.dateValue
                
                // Safely encode the string array to binary data if the type is a List
                if let list = structCF.listValue, let data = try? JSONEncoder().encode(list) {
                    cfEntity.textListValueData = data
                }
                
                // Step 1: Link or Create the global CustomFieldEntity definition
                if let definition = structCF.definition {
                    let defReq: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
                    defReq.predicate = NSPredicate(format: "id == %@", definition.id as CVarArg)
                    
                    if let existingDef = try context.fetch(defReq).first {
                        // The label/type already exists globally, simply link it to the value.
                        cfEntity.definition = existingDef
                    } else {
                        // The user created a brand new custom field label.
                        // Save the new definition to the database globally and link it.
                        let newDef = CustomFieldEntity(context: context)
                        newDef.id = definition.id
                        newDef.label = definition.label
                        newDef.dataType = definition.dataType.rawValue
                        
                        cfEntity.definition = newDef
                    }
                }
            }
            
            // 5. Map Schedule (One-to-One Owned)
            if let existingSchedule = entity.schedule {
                context.delete(existingSchedule)
            }
            
            if let structSchedule = medicine.schedule {
                let scheduleEntity = ScheduleEntity(context: context)
                scheduleEntity.id = structSchedule.id
                scheduleEntity.startDate = structSchedule.startDate
                scheduleEntity.endDate = structSchedule.endDate
                scheduleEntity.repeatType = structSchedule.repeatType.rawValue
                scheduleEntity.medicine = entity
                
                // Map the Days enum array using the Transformable objective-C bridge
                scheduleEntity.selectedDays = structSchedule.selectedDays.map { $0.rawValue } as NSArray
                
                // Encode the complex DateComponents array into Binary Data
                if let datesData = try? JSONEncoder().encode(structSchedule.selectedDates) {
                    scheduleEntity.selectedDatesData = datesData
                }
                
                // Rebuild Reminder Times
                for reminder in structSchedule.reminderTimes {
                    let reminderEntity = ReminderTimeEntity(context: context)
                    reminderEntity.id = reminder.id
                    reminderEntity.time = reminder.time
                    reminderEntity.schedule = scheduleEntity
                }
            }
            
            // Execute the save
            if context.hasChanges {
                try context.save()
            }
            
        } catch {
            context.rollback()
            throw error
        }
    }
    
    /// Deletes a medicine record by its UUID.
    /// - Parameter id: The unique identifier of the medicine to delete.
    func deleteMedicine(id: UUID) throws {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
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
    
    /// Deletes all medicines from the database, ensuring CloudKit syncs the deletions.
    public func deleteAllMedicines() throws {
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
    
    // MARK: - CloudKit Sharing
    
    /// Generates a CloudKit Share for a specific medicine.
    /// - Parameter medicine: The medicine struct to share.
    /// - Returns: A tuple containing the new (or existing) CKShare and the CKContainer.
    func createShare(for medicine: Medicine) async throws -> (CKShare, CKContainer) {
        // 1. Fetch the actual Core Data entity
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicine.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "MedicineManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Medicine not found in database."])
        }
        
        // 2. Access your persistent container
        let container = PersistenceController.shared.container
        
        // 3. Ask Core Data to create the share record
        // If the item is already shared, this safely returns the existing share.
        let (_, share, ckContainer) = try await container.share([entity], to: nil)
        
        // 4. Configure the share's basic metadata
        share[CKShare.SystemFieldKey.title] = medicine.name as CKRecordValue
        
        // Save the context so the share is pushed to iCloud
        try context.save()
        
        return (share, ckContainer)
    }
    
    public func fetchOrCreateShare(for medicine: Medicine) async throws -> (CKShare, CKContainer) {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicine.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "MedicineManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Medicine not found."])
        }
        
        let container = PersistenceController.shared.container

        // Extract the CloudKit container identifier from your configured store descriptions
        guard let storeDescription = container.persistentStoreDescriptions.first,
              let containerIdentifier = storeDescription.cloudKitContainerOptions?.containerIdentifier else {
            throw NSError(domain: "MedicineManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "CloudKit container not configured."])
        }

        // Instantiate the pure CloudKit container object
        let actualCKContainer = CKContainer(identifier: containerIdentifier)

        // 1. ALWAYS check if it is already shared (either by you or someone else)
        if let existingShares = try? container.fetchShares(matching: [entity.objectID]),
           let share = existingShares[entity.objectID] {
            // Return the actual CKContainer to satisfy the tuple requirement
            return (share, actualCKContainer)
        }
        
        // 2. If it is NOT shared, create a new one
        let (_, share, ckContainer) = try await container.share([entity], to: nil)
        share[CKShare.SystemFieldKey.title] = medicine.name as CKRecordValue
        try context.save()
        
        return (share, ckContainer)
    }
    
    // MARK: - Private Mapping Methods (Entity to Struct)
    
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
                textListValue: decodedList,
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
