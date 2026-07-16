//
//  MedicineExtensions.swift
//  MedKit
//
//  Created by Rishik Dev on 25/06/26.
//

import Foundation

extension Medicine {
    /// Converts an object of `CodableMedicineModel` to `Medicine`.
    /// - Parameter codableMedicineModel: Object of type `CodableMedicineModel` to be converted.
    init(fromCodable codableMedicineModel: CodableMedicineModel) {
        // Attributes present on the medicine package
        self.name = codableMedicineModel.name
        self.manufacturedDate = codableMedicineModel.manufacturedDate
        self.expiryDate = codableMedicineModel.expiryDate
        self.strengthAmount = codableMedicineModel.strengthAmount
        self.strengthUnit = codableMedicineModel.strengthUnit
        
        self.composition = codableMedicineModel.composition.map {
            Ingredient(
                name: $0.name,
                strengthAmount: $0.strengthAmount,
                strengthUnit: $0.strengthUnit
            )
        }
        
        // Attributes NOT present on the medicine package
        self.id = UUID()
        self.stock = nil
        self.doseQuantity = nil
        self.schedule = nil
        self.tags = []
        self.customFields = []
    }
}
