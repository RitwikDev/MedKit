//
//  CustomFieldModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class CustomFieldModel {
    var label: String
    var type: CustomFieldTypeEnum
    
    init(label: String = "", type: CustomFieldTypeEnum = .Text) {
        self.label = label
        self.type = type
    }
}
