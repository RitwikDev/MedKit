//
//  CustomFieldExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

import Foundation

extension CustomField {
    init(from model: CustomFieldModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.label = model.label
        self.dataType = model.dataType
    }
    
    func isValid() -> Bool {
        return !self.label.trimmedIsEmpty
    }
}
