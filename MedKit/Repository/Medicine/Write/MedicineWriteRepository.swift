//
//  MedicineWriteRepository.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//

import Foundation
import SwiftData

class MedicineWriteRepository
{
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func save(medicine: Medicine) throws -> MedicineModel {
        let medicineModel = self.getModel(from: medicine)
        self.applyMedicineValues(from: medicine, to: medicineModel)
        
        if medicine.persistentIdentifier == nil {
            self.modelContext.insert(medicineModel)
        }
        
        do {
            try self.modelContext.save()
            return medicineModel
        } catch {
            print("Failed to save medicine \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getModel(from medicine: Medicine) -> MedicineModel {
        if let persistentId = medicine.persistentIdentifier {
            guard let model = self.tryGetExistingMedicineModel(forId: persistentId) else {
                return MedicineModel()
            }
            
            return model
        }
        
        return MedicineModel()
    }
    
    private func tryGetExistingMedicineModel(
        forId persistentId: PersistentIdentifier,
    ) -> MedicineModel? {
        guard let existingModel = self.modelContext.model(for: persistentId) as? MedicineModel else { return nil }
        
        return existingModel
    }
    
    private func applyMedicineValues(from medicineStruct: Medicine, to medicineModel: MedicineModel) -> Void {
        self.applyBasicProperties(from: medicineStruct, to: medicineModel)
        self.applyComposition(from: medicineStruct, to: medicineModel)
        self.applySchedule(from: medicineStruct, to: medicineModel)
        self.applyTags(for: medicineModel, with: medicineStruct.tags)
        self.applyCustomFields(from: medicineStruct, to: medicineModel)
    }
    
    private func applyBasicProperties(from medicineStruct: Medicine, to medicineModel: MedicineModel) -> Void {
        medicineModel.name = medicineStruct.name
        medicineModel.quantity = medicineStruct.quantity
        medicineModel.manufacturedDate = medicineStruct.manufacturedDate
        medicineModel.expiryDate = medicineStruct.expiryDate
        medicineModel.strengthAmount = medicineStruct.strengthAmount
        medicineModel.strengthUnit = medicineStruct.strengthUnit
    }
    
    private func applyComposition(from medicineStruct: Medicine, to medicineModel: MedicineModel) -> Void {
        for ingredient in medicineModel.composition {
            self.modelContext.delete(ingredient)
        }
        medicineModel.composition.removeAll()
        
        // Insert updated child ingredients from the UI struct
        medicineModel.composition = medicineStruct.composition.map {
            IngredientModel(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit)
        }
    }
    
    private func applySchedule(from medicineStruct: Medicine, to medicineModel: MedicineModel) -> Void {
        if let schedule = medicineStruct.schedule {
            medicineModel.schedule = ScheduleModel(from: schedule)
        } else {
            medicineModel.schedule = nil
        }
    }
    
    private func applyTags(for model: MedicineModel, with uiTags: [Tag]) -> Void {
        model.tags.removeAll()
        
        for uiTag in uiTags {
            let tagValue = uiTag.value
            let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.value == tagValue })
            
            if let existingGlobalTag = try? self.modelContext.fetch(descriptor).first {
                model.tags.append(existingGlobalTag)
            } else {
                let newTag = TagModel(value: tagValue)
                model.tags.append(newTag)
            }
        }
    }
    
    private func applyCustomFields(from medicineStruct: Medicine, to medicineModel: MedicineModel) -> Void {
        for field in medicineModel.customFields {
            self.modelContext.delete(field)
        }
        medicineModel.customFields.removeAll()
        
        medicineModel.customFields = medicineStruct.customFields.map {
            let definitionModel = self.getCustomFieldModel(for: $0.definition)
            
            return CustomFieldValueModel(
                textValue: $0.textValue,
                dateValue: $0.dateValue,
                textListValue: $0.listValue,
                definition: definitionModel,
                medicine: medicineModel,
            )
        }
    }
    
    private func getCustomFieldModel(for customFieldStruct: CustomField?) -> CustomFieldModel {
        if customFieldStruct == nil {
            return CustomFieldModel()
        }
        
        if let persistentId = customFieldStruct?.persistentIdentifier {
            guard let existingDefinitionModel = self.modelContext.model(for: persistentId) as? CustomFieldModel else {
                return CustomFieldModel()
            }
            
            return existingDefinitionModel
        }
        
        return CustomFieldModel()
    }
}
