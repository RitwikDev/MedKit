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
    let persistentIdentifier: PersistentIdentifier?
    
    var label: String
    var dataType: CustomFieldDataType
    
    init(
        id: UUID = UUID(),
        persistentIdentifier: PersistentIdentifier? = nil,
        label: String = "",
        dataType: CustomFieldDataType = .text
    ) {
        self.id = id
        self.persistentIdentifier = persistentIdentifier
        self.label = label
        self.dataType = dataType
    }
}
