//
//  CustomFieldValueExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//


import Foundation

extension CustomFieldValue {
    func isValid() -> Bool {
        return (self.textValue != nil && !(self.textValue?.trimmedIsEmpty ?? true))
        || self.dateValue != nil
        || (self.listValue != nil && !(self.listValue?.isEmpty ?? true))
    }
}
