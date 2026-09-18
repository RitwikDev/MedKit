//
//  CustomFieldValueExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//


import Foundation

enum InvalidFieldEnum: String, Error {
    case text = "Text is not valid. Please write something in the textfield."
    case date = "Date is not valid. Please select a valid date."
    case list = "List is not valid. Please add at least one value to the list."
    case file = "No file or photo added. Please add one."
    case field = "Field is not valid"
    case none = "None"
}

extension CustomFieldValue {
    func isValid() -> (Bool, InvalidFieldEnum) {
        switch self.definition?.dataType {
        case .text:
            if (self.textValue != nil && !(self.textValue?.trimmedIsEmpty ?? true)) {
                return (true, .none)
            } else {
                return (false, .text)
            }
        case .date:
            if (self.dateValue != nil) {
                return (true, .none)
            } else {
                return (false, .date)
            }
        case .list:
            if (self.listValue != nil && !(self.listValue?.isEmpty ?? true)) {
                return (true, .none)
            } else {
                return (false, .list)
            }
        case .documents:
            if (self.documentValue != nil && !(self.documentValue?.isEmpty ?? true)) {
                return (true, .none)
            } else {
                return (false, .file)
            }
        case .none:
            return (false, .field)
        }
    }
}
