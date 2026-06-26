//
//  CustomFieldExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

import Foundation

extension CustomField {
    func isValid() -> Bool {
        return !self.label.trimmedIsEmpty
    }
}
