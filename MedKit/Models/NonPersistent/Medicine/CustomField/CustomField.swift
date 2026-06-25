//
//  CustomField.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//


import Foundation
import SwiftData

struct CustomField: Identifiable, Equatable, Hashable {
    let id: UUID
    var label: String
    var dataType: CustomFieldDataType
    
    init(
        id: UUID = UUID(),
        label: String = "",
        dataType: CustomFieldDataType = .text
    ) {
        self.id = id
        self.label = label
        self.dataType = dataType
    }
}
