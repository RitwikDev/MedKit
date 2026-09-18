//
//  MedicineWriteManager.swift
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
class MedicineWriteManager {
    
    /// The shared singleton instance.
    static let shared = MedicineWriteManager()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
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
            // Identify the store (private or shared) where this specific medicine lives
            let targetStore = entity.objectID.persistentStore
            
            // 1. Map Basic Attributes
            entity.id = medicine.id
            entity.name = medicine.name
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
                
                // Restrict the search to the medicine's store
                if let store = targetStore {
                    tagReq.affectedStores = [store]
                }
                
                if let existingTag = try context.fetch(tagReq).first {
                    linkedTags.insert(existingTag)
                } else {
                    let newTag = TagEntity(context: context)
                    newTag.id = structTag.id
                    newTag.value = structTag.value
                    
                    // Explicitly create the new tag in the same store
                    if let store = targetStore {
                        context.assign(newTag, to: store)
                    }
                    
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
                    
                    if let store = targetStore {
                        defReq.affectedStores = [store]
                    }
                    
                    if let existingDef = try context.fetch(defReq).first {
                        cfEntity.definition = existingDef
                    } else {
                        let newDef = CustomFieldEntity(context: context)
                        newDef.id = definition.id
                        newDef.label = definition.label
                        newDef.dataType = definition.dataType.rawValue
                        cfEntity.definition = newDef
                        
                        if let store = targetStore {
                            context.assign(newDef, to: store)
                        }
                    }
                }
            }
            
            // Cleanup removed custom fields
            for oldField in existingCustomFields {
                if let oldID = oldField.id, !matchedCustomFieldIDs.contains(oldID) {
                    context.delete(oldField)
                }
            }
            
            // 5. Map Dosage
            if let structDosage = medicine.dosage {
                // Get existing dosage or create a new one
                let dosageEntity = entity.dosage ?? DosageEntity(context: context)
                
                dosageEntity.id = structDosage.id
                dosageEntity.dosageQuantity = structDosage.dosageQuantity ?? 0
                dosageEntity.startDate = structDosage.startDate
                dosageEntity.endDate = structDosage.endDate
                dosageEntity.repeatType = structDosage.repeatType.rawValue
                dosageEntity.medicine = entity
                
                dosageEntity.selectedDays = structDosage.selectedDays.map { $0.rawValue } as NSArray
                
                if let datesData = try? JSONEncoder().encode(structDosage.selectedDates) {
                    dosageEntity.selectedDatesData = datesData
                }
                
                // 5b. Map Reminders
                let existingReminders = (dosageEntity.reminderTimes as? Set<ReminderTimeEntity>) ?? []
                var matchedReminderIDs = Set<UUID>()
                
                for reminder in structDosage.reminderTimes {
                    matchedReminderIDs.insert(reminder.id)
                    
                    let reminderEntity = existingReminders.first(where: { $0.id == reminder.id })
                                         ?? ReminderTimeEntity(context: context)
                    
                    reminderEntity.id = reminder.id
                    reminderEntity.time = reminder.time
                    reminderEntity.dosage = dosageEntity
                }
                
                // Cleanup removed reminders
                for oldReminder in existingReminders {
                    if let oldID = oldReminder.id, !matchedReminderIDs.contains(oldID) {
                        context.delete(oldReminder)
                    }
                }
                
            } else if let existingDosage = entity.dosage {
                // If the draft has no dosage, but the entity does, the user deleted it.
                context.delete(existingDosage)
            }
            
            // 6. Map stock
            if let stockStruct = medicine.stock {
                let stockEntity = entity.stock ?? StockEntity(context: context)
                stockEntity.id = stockStruct.id
                stockEntity.quantity = stockStruct.quantity
                stockEntity.unit = stockStruct.unit
                stockEntity.endDate = stockStruct.endDate
                stockEntity.medicine = entity
            } else if let existingStock = entity.stock {
                context.delete(existingStock)
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
    public func fetchOrCreateShare(for medicine: Medicine) async throws -> (CKShare, CKContainer) {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicine.id as CVarArg)
        
        guard let entity = try context.fetch(request).first else {
            throw NSError(domain: "MedicineManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Medicine not found."])
        }
        
        // 1. Flush any pending changes to the SQLite store before sharing
        if context.hasChanges {
            try context.save()
        }
        
        let container = PersistenceController.shared.container

        guard let storeDescription = container.persistentStoreDescriptions.first,
              let containerIdentifier = storeDescription.cloudKitContainerOptions?.containerIdentifier else {
            throw NSError(domain: "MedicineManager", code: 500, userInfo: [NSLocalizedDescriptionKey: "CloudKit container not configured."])
        }

        let actualCKContainer = CKContainer(identifier: containerIdentifier)

        // 2. Check if already shared
        if let existingShares = try? container.fetchShares(matching: [entity.objectID]),
           let share = existingShares[entity.objectID] {
            return (share, actualCKContainer)
        }
        
        // 3. Create a new share with a fallback for the mirroring delegate race condition
        do {
            let (_, share, ckContainer) = try await container.share([entity], to: nil)
            share[CKShare.SystemFieldKey.title] = medicine.name as CKRecordValue
            try context.save()
            
            return (share, ckContainer)
        } catch {
            // 4. If the mirroring delegate aborted (e.g., due to an in-flight private sync),
            // the CKShare is usually still successfully created in the local context.
            if let existingShares = try? container.fetchShares(matching: [entity.objectID]),
               let share = existingShares[entity.objectID] {
                
                // Configure the title and save the context again just to be safe
                share[CKShare.SystemFieldKey.title] = medicine.name as CKRecordValue
                try? context.save()
                
                return (share, actualCKContainer)
            }
            
            // If the share truly wasn't created, rethrow the original error
            throw error
        }
    }

}
