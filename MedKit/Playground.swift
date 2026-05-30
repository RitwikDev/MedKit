//
//  Playground.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation
import SwiftData

enum DatabaseTypeEnum {
    case all, medicines, compositions, tags
}

func saveOrUpdateMedicine(from medicineStruct: Medicine, in context: ModelContext) {
    if let persistentId = medicineStruct.persistentIdentifier {
        // SCENARIO A: EDITING AN EXISTING RECORD
        guard let existingModel = context.model(for: persistentId) as? MedicineModel else { return }
        
        // 1. Update basic fields
        existingModel.name = medicineStruct.name
        existingModel.quantity = medicineStruct.quantity
        existingModel.manufacturedDate = medicineStruct.manufacturedDate
        existingModel.expiryDate = medicineStruct.expiryDate
        existingModel.strengthAmount = medicineStruct.strengthAmount
        existingModel.strengthUnit = medicineStruct.strengthUnit
        
        // 2. Clear old child compositions out completely (Cascade delete handles cleanup)
        for composition in existingModel.composition {
            context.delete(composition)
        }
        existingModel.composition.removeAll()
        
        // 3. Insert updated child compositions from the UI struct
        existingModel.composition = medicineStruct.composition.map {
            CompositionModel(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit)
        }
        
        // 4. Re-sync many-to-many unique tags safely
        syncTags(for: existingModel, with: medicineStruct.tags, in: context)
        
    } else {
        // SCENARIO B: CREATING A BRAND NEW RECORD
        let newMedicineModel = MedicineModel(
            name: medicineStruct.name,
            quantity: medicineStruct.quantity,
            manufacturedDate: medicineStruct.manufacturedDate,
            expiryDate: medicineStruct.expiryDate,
            strengthAmount: medicineStruct.strengthAmount,
            strengthUnit: medicineStruct.strengthUnit
        )
        
        newMedicineModel.composition = medicineStruct.composition.map {
            CompositionModel(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit)
        }
        
        context.insert(newMedicineModel)
        
        // Link unique tags on a freshly inserted model instance
        syncTags(for: newMedicineModel, with: medicineStruct.tags, in: context)
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

@MainActor
func deleteAllData(from context: ModelContext, of type: DatabaseTypeEnum = .all) {
    print("Initiating complete database wipe...")
    
    do {
        // Run batch deletes on concrete types so the #Predicate macro can resolve them perfectly
        
        if (type == .all || type == .medicines) {
            try context.delete(model: MedicineModel.self, where: #Predicate<MedicineModel> { _ in true })
        }
        
        if (type == .all || type == .compositions) {
            // TODO: This delete operation is throwing an error
            try context.delete(model: CompositionModel.self, where: #Predicate<CompositionModel> { _ in true })
        }
        
        if (type == .all || type == .tags) {
            try context.delete(model: TagModel.self, where: #Predicate<TagModel> { _ in true })
        }
        
        // Push the changes instantly to the underlying SQLite database file
        try context.save()
        print("Database cleared successfully.")
        
    } catch {
        print("Failed to clear database of type \(type): \(error.localizedDescription)")
    }
}
