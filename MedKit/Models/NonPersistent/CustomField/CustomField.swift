//
//  CustomField.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation

struct CustomField {
    var label: String
    var value: CustomFieldTypeEnum
    
    init(label: String = "", value: CustomFieldTypeEnum = .text("")) {
        self.label = label
        self.value = value
    }
}
