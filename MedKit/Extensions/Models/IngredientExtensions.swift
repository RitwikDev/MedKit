//
//  IngredientExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Ingredient {
    var fullName: String {
        if let amount = strengthAmount, let unit = strengthUnit {
            return "\(name.trimmed) \(amount.formatted(.number)) \(unit.trimmed)"
        } else {
            return name
        }
    }
    
    func isDuplicate(of other: Ingredient) -> Bool {
        return self.id != other.id
        && self.fullName.trimmedLocalizedCaseInsensitiveEquals(other.fullName)
    }
    
    func isValid() -> Bool {
        if (name.trimmedIsEmpty) {
            return false
        }
        
        let bothNil = strengthAmount == nil && strengthUnit == nil
        let bothValid = (strengthAmount ?? -1) > 0 && !(strengthUnit ?? "").trimmedIsEmpty
                
        return bothNil || bothValid
    }
}
