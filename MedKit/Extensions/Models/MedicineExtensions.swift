//
//  MedicineExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Medicine {
    init(from model: MedicineModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.name = model.name
        self.quantity = model.quantity
        self.manufacturedDate = model.manufacturedDate
        self.expiryDate = model.expiryDate
        self.strengthAmount = model.strengthAmount
        self.strengthUnit = model.strengthUnit
        
        self.composition = model.composition.map { Ingredient(from: $0) }
        self.schedule = Schedule(from: model.schedule ?? .init())
        self.tags = model.tags.map { Tag(from: $0) }
        self.customFields = model.customFields.map { CustomFieldValue(from: $0) }
    }
}
