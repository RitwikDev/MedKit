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
            
            // 2. Map Ingredients
            let existingIngredients = (entity.composition as? Set<IngredientEntity>) ?? []
            var matchedIngredientIDs = Set<UUID>()
            
            for structIngredient in medicine.composition {
                matchedIngredientIDs.insert(structIngredient.id)
                
                let ingredientEntity = existingIngredients.first(where: { $0.id == structIngredient.id })
                                       ?? IngredientEntity(context: context)
                
                ingredientEntity.id = structIngredient.id
                ingredientEntity.name = structIngredient.name
                ingredientEntity.strengthAmount = structIngredient.strengthAmount ?? 0
                ingredientEntity.strengthUnit = structIngredient.strengthUnit
                ingredientEntity.medicine = entity
            }
            
            // Cleanup removed ingredients
            for oldIngredient in existingIngredients {
                if let oldID = oldIngredient.id, !matchedIngredientIDs.contains(oldID) {
                    context.delete(oldIngredient)
                }
            }
            
            // 3. Map Tags (Many-to-Many Shared)
            var linkedTags = Set<TagEntity>()
            for structTag in medicine.tags {
                let tagReq: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
                tagReq.predicate = NSPredicate(format: "id == %@", structTag.id as CVarArg)
                
                if let existingTag = try context.fetch(tagReq).first {
                    linkedTags.insert(existingTag)
                } else {
                    let newTag = TagEntity(context: context)
                    newTag.id = structTag.id
                    newTag.value = structTag.value
                    linkedTags.insert(newTag)
                }
            }
            entity.tags = linkedTags as NSSet
            
            // 4. Map Custom Fields
            let existingCustomFields = (entity.customFields as? Set<CustomFieldValueEntity>) ?? []
            var matchedCustomFieldIDs = Set<UUID>()
            
            for structCF in medicine.customFields {
                matchedCustomFieldIDs.insert(structCF.id)
                
                let cfEntity = existingCustomFields.first(where: { $0.id == structCF.id })
                               ?? CustomFieldValueEntity(context: context)
                
                cfEntity.id = structCF.id
                cfEntity.medicine = entity
                cfEntity.textValue = structCF.textValue
                cfEntity.dateValue = structCF.dateValue
                
                if let list = structCF.listValue, let data = try? JSONEncoder().encode(list) {
                    cfEntity.textListValueData = data
                }
                
                let existingDocuments = (cfEntity.documents as? Set<DocumentEntity>) ?? []
                var matchedDocumentIDs = Set<UUID>()

                if let structDocuments = structCF.documentValue {
                    for structDocument in structDocuments {
                        matchedDocumentIDs.insert(structDocument.id)
                        
                        let documentEntity = existingDocuments.first(where: { $0.id == structDocument.id })
                                               ?? DocumentEntity(context: context)
                        
                        documentEntity.id = structDocument.id
                        documentEntity.name = structDocument.name
                        documentEntity.documentExtension = structDocument.documentExtension
                        documentEntity.documentData = structDocument.documentData
                        documentEntity.type = structDocument.documentType.rawValue
                        documentEntity.customFieldValue = cfEntity // Set the inverse relationship
                    }
                }

                for oldDocument in existingDocuments {
                    if let oldID = oldDocument.id, !matchedDocumentIDs.contains(oldID) {
                        context.delete(oldDocument)
                    }
                }
                
                if let definition = structCF.definition {
                    let defReq: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
                    defReq.predicate = NSPredicate(format: "id == %@", definition.id as CVarArg)
                    
                    if let existingDef = try context.fetch(defReq).first {
                        cfEntity.definition = existingDef
                    } else {
                        let newDef = CustomFieldEntity(context: context)
                        newDef.id = definition.id
                        newDef.label = definition.label
                        newDef.dataType = definition.dataType.rawValue
                        cfEntity.definition = newDef
                    }
                }
            }
            
            // Cleanup removed custom fields
            for oldField in existingCustomFields {
                if let oldID = oldField.id, !matchedCustomFieldIDs.contains(oldID) {
                    context.delete(oldField)
                }
            }
            
            // 5. Map Schedule
            if let structSchedule = medicine.schedule {
                // Get existing schedule or create a new one
                let scheduleEntity = entity.schedule ?? ScheduleEntity(context: context)
                
                scheduleEntity.id = structSchedule.id
                scheduleEntity.startDate = structSchedule.startDate
                scheduleEntity.endDate = structSchedule.endDate
                scheduleEntity.repeatType = structSchedule.repeatType.rawValue
                scheduleEntity.medicine = entity
                
                scheduleEntity.selectedDays = structSchedule.selectedDays.map { $0.rawValue } as NSArray
                
                if let datesData = try? JSONEncoder().encode(structSchedule.selectedDates) {
                    scheduleEntity.selectedDatesData = datesData
                }
                
                // 5b. Map Reminders
                let existingReminders = (scheduleEntity.reminderTimes as? Set<ReminderTimeEntity>) ?? []
                var matchedReminderIDs = Set<UUID>()
                
                for reminder in structSchedule.reminderTimes {
                    matchedReminderIDs.insert(reminder.id)
                    
                    let reminderEntity = existingReminders.first(where: { $0.id == reminder.id })
                                         ?? ReminderTimeEntity(context: context)
                    
                    reminderEntity.id = reminder.id
                    reminderEntity.time = reminder.time
                    reminderEntity.schedule = scheduleEntity
                }
                
                // Cleanup removed reminders
                for oldReminder in existingReminders {
                    if let oldID = oldReminder.id, !matchedReminderIDs.contains(oldID) {
                        context.delete(oldReminder)
                    }
                }
                
            } else if let existingSchedule = entity.schedule {
                // If the draft has no schedule, but the entity does, the user deleted it.
                context.delete(existingSchedule)
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
        }.sorted { $0.name < $1.name }
        
        // 2. Map Tags
        let tagEntities = entity.tags as? Set<TagEntity> ?? []
        let tags = tagEntities.map {
            Tag(
                id: $0.id ?? UUID(),
                value: $0.value ?? ""
            )
        }.sorted { $0.value < $1.value }
        
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
        }.sorted { $0.definition?.label ?? "" < $1.definition?.label ?? "" }
        
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
