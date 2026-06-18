//
//  IngredientExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Ingredient {
    init(from model: IngredientModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.name = model.name
        self.strengthAmount = model.strengthAmount
        self.strengthUnit = model.strengthUnit
    }
    
    var fullName: String {
        if let amount = strengthAmount, let unit = strengthUnit {
            return "\(name.trimmed) \(amount) \(unit.trimmed)"
        } else {
            return name
        }
    }
    
    func isDuplicate(of other: Ingredient) -> Bool {
        return self.id != other.id
        && self.name == other.name
        && self.strengthAmount == other.strengthAmount
        && self.strengthUnit == other.strengthUnit
    }
    
    func equalsId(_ otherIngredient: Ingredient) -> Bool {
        self.id == otherIngredient.id
    }
    
    func equalsPersistentId(_ otherIngredient: Ingredient) -> Bool {
        self.persistentIdentifier == otherIngredient.persistentIdentifier
    }
    
    func equalsName(_ otherIngredient: Ingredient) -> Bool {
        self.name.lowercasedAndTrimmed == otherIngredient.name.lowercasedAndTrimmed
    }
    
    func equalsFullName(_ otherIngredient: Ingredient) -> Bool {
        self.fullName.lowercasedAndTrimmed == otherIngredient.fullName.lowercasedAndTrimmed
    }
    
    func isValid() -> Bool {
        guard !name.trimmedIsEmpty else { return false }
        
        let bothNil = (strengthAmount == nil && strengthUnit == nil)
        let bothValid = (strengthAmount ?? 0) > 0 && !(strengthUnit ?? "").trimmedIsEmpty
        
        return bothNil || bothValid
    }
}
