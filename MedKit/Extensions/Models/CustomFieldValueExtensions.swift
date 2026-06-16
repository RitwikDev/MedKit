//
//  CustomFieldValueExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

import Foundation

extension CustomFieldValue {
    init(from model: CustomFieldValueModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.textValue = model.textValue
        self.dateValue = model.dateValue
        self.listValue = model.textListValue
        
        if let customField = model.definiion {
            self.definition = CustomField(from: customField)
        } else {
            self.definition = nil
        }
    }
    
    func isValid() -> Bool {
        return (self.textValue != nil && !(self.textValue?.trimmedIsEmpty ?? true))
        || self.dateValue != nil
        || (self.listValue != nil && !(self.listValue?.isEmpty ?? true))
    }
}
