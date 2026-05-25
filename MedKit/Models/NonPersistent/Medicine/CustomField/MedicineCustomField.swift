//
//  MedicineCustomField.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation

struct MedicineCustomField {
    var customFieldId: UUID
    var value: MedicineCustomFieldValueTypeEnum
    
    init(customFieldId: UUID = UUID(), value: MedicineCustomFieldValueTypeEnum = .text("")) {
        self.customFieldId = customFieldId
        self.value = value
    }
}
