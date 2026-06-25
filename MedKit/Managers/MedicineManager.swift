import Foundation
import CoreData

/// A singleton manager responsible for all database transactions.
/// It translates pure Swift structs into Core Data entities and vice versa,
/// ensuring the UI and ViewModels remain completely decoupled from the database framework.
public final class MedicineManager {
    
    /// The shared singleton instance.
    public static let shared = MedicineManager()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    // MARK: - Fetching
    
    /// Fetches all medicines from the database and translates them into pure Swift structs.
    /// - Returns: An array of `Medicine` structs sorted alphabetically by name.
    public func fetchAllMedicines() -> [Medicine] {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { mapToStruct(entity: $0) }
        } catch {
            print("Manager Error - Failed to fetch medicines: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Saving & Deleting
    
    /// Saves a pure `Medicine` struct to the database (Upsert pattern).
    /// - Parameter medicine: The finalized draft struct to save.
    public func save(_ medicine: Medicine) {
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
                    existingTag.value = structTag.value // Update value in case it changed
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
            if let existingCustomFields = entity.customFields as? Set<CustomFieldValueEntity> {
                existingCustomFields.forEach { context.delete($0) }
            }
            
            for structCF in medicine.customFields {
                let cfEntity = CustomFieldValueEntity(context: context)
                cfEntity.id = structCF.id
                cfEntity.textValue = structCF.textValue
                cfEntity.dateValue = structCF.dateValue
                cfEntity.medicine = entity
                
                // Safely encode the string array to binary data
                if let list = structCF.listValue, let data = try? JSONEncoder().encode(list) {
                    cfEntity.textListValue = data
                }
                
                // Link to the global CustomFieldEntity definition
                if let definitionID = structCF.definition?.id {
                    let defReq: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
                    defReq.predicate = NSPredicate(format: "id == %@", definitionID as CVarArg)
                    cfEntity.definition = try context.fetch(defReq).first
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
                scheduleEntity.selectedDays = structSchedule.selectedDays.map { $0.rawValue } as NSObject
                
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
            print("Manager Error - Failed to save medicine: \(error.localizedDescription)")
            context.rollback()
        }
    }
    
    /// Deletes a medicine record by its UUID.
    /// - Parameter id: The unique identifier of the medicine to delete.
    public func delete(by id: UUID) {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            print("Manager Error - Failed to delete medicine: \(error.localizedDescription)")
        }
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
            if let data = cfEntity.textListValue, let list = try? JSONDecoder().decode([String].self, from: data) {
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
            let rawDays = scheduleEntity.selectedDays as? [String] ?? []
            let mappedDays = rawDays.compactMap { Day(rawValue: $0) }
            
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