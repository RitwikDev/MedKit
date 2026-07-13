//
//  MedicineReadManager.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import CoreData
import Foundation

class MedicineReadManager {
    static let shared: MedicineReadManager = .init()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    public func fetchById(_ id: UUID) throws -> Medicine {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(request)
        let entity = results.first ?? MedicineEntity(context: context)
        
        return mapToStruct(entity: entity)
    }
    
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
            stockQuantity: entity.stockQuantity > 0 ? entity.stockQuantity : nil,
            stockUnit: entity.stockUnit,
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
