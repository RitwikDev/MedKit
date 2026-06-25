//
//  CustomFieldWriteRepository.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//

/*
import Foundation
import SwiftData

class CustomFieldWriteRepository
{
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func save(field: CustomField) throws -> CustomFieldModel {
        let customFieldModel = self.getModel(from: field)
        customFieldModel.label = field.label
        customFieldModel.dataType = field.dataType
        
        if field.persistentIdentifier == nil {
            self.modelContext.insert(customFieldModel)
        }
        
        do {
            try self.modelContext.save()
            
            return customFieldModel
        } catch {
            print("Failed to save custom field: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getModel(from customField: CustomField) -> CustomFieldModel {
        if let persistentId = customField.persistentIdentifier {
            guard let model = self.tryGetExistingCustomFieldModel(forId: persistentId) else {
                return CustomFieldModel()
            }
            
            return model
        }
        
        return CustomFieldModel()
    }
    
    private func tryGetExistingCustomFieldModel(
        forId persistentId: PersistentIdentifier,
    ) -> CustomFieldModel? {
        guard let existingModel = self.modelContext.model(for: persistentId) as? CustomFieldModel else { return nil }
        
        return existingModel
    }
}
*/
