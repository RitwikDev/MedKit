//
//  CompositionExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Composition {
    init(from model: CompositionModel) {
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
    
    func isDuplicate(of other: Composition) -> Bool {
        return self.id != other.id
        && self.name == other.name
        && self.strengthAmount == other.strengthAmount
        && self.strengthUnit == other.strengthUnit
    }
    
    func equalsId(_ otherComposition: Composition) -> Bool {
        self.id == otherComposition.id
    }
    
    func equalsName(_ otherComposition: Composition) -> Bool {
        self.name.lowercasedAndTrimmed == otherComposition.name.lowercasedAndTrimmed
    }
    
    func equalsFullName(_ otherComposition: Composition) -> Bool {
        self.fullName.lowercasedAndTrimmed == otherComposition.fullName.lowercasedAndTrimmed
    }
    
    func isValid() -> Bool {
        guard !name.trimmedIsEmpty else { return false }
        
        let bothNil = (strengthAmount == nil && strengthUnit == nil)
        let bothValid = (strengthAmount ?? 0) > 0 && !(strengthUnit ?? "").trimmedIsEmpty
        
        return bothNil || bothValid
    }
}
