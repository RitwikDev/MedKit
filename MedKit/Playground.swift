//
//  Playground.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation
import SwiftData

func saveOrUpdateMedicine(from uiStruct: Medicine, in context: ModelContext) {
    if let dbID = uiStruct.persistentIdentifier {
        // SCENARIO A: EDITING AN EXISTING RECORD
        guard let existingModel = context.model(for: dbID) as? MedicineModel else { return }
        
        // 1. Update basic fields
        existingModel.name = uiStruct.name
        existingModel.quantity = uiStruct.quantity
        existingModel.manufacturedDate = uiStruct.manufacturedDate
        existingModel.expiryDate = uiStruct.expiryDate
        existingModel.strengthAmount = uiStruct.strengthAmount
        existingModel.strengthUnit = uiStruct.strengthUnit
        
        // 2. Clear old child compositions out completely (Cascade delete handles cleanup)
        for composition in existingModel.composition {
            context.delete(composition)
        }
        existingModel.composition.removeAll()
        
        // 3. Insert updated child compositions from the UI struct
        existingModel.composition = uiStruct.composition.map {
            CompositionModel(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit)
        }
        
        // 4. Re-sync many-to-many unique tags safely
        syncTags(for: existingModel, with: uiStruct.tags, in: context)
        
    } else {
        // SCENARIO B: CREATING A BRAND NEW RECORD
        let newMedicineModel = MedicineModel(
            name: uiStruct.name,
            quantity: uiStruct.quantity,
            manufacturedDate: uiStruct.manufacturedDate,
            expiryDate: uiStruct.expiryDate,
            strengthAmount: uiStruct.strengthAmount,
            strengthUnit: uiStruct.strengthUnit
        )
        
        newMedicineModel.composition = uiStruct.composition.map {
            CompositionModel(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit)
        }
        
        context.insert(newMedicineModel)
        
        // Link unique tags on a freshly inserted model instance
        syncTags(for: newMedicineModel, with: uiStruct.tags, in: context)
    }
    
    // Save your context safely to disk
    try? context.save()
}

/// Helper method to safely resolve tag links without creating non-unique database duplicates
private func syncTags(for model: MedicineModel, with uiTags: [Tag], in context: ModelContext) {
    model.tags.removeAll()
    
    for uiTag in uiTags {
        let tagValue = uiTag.value
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.value == tagValue })
        
        if let existingGlobalTag = try? context.fetch(descriptor).first {
            model.tags.append(existingGlobalTag)
        } else {
            let newTag = TagModel(value: tagValue)
            model.tags.append(newTag)
        }
    }
}
