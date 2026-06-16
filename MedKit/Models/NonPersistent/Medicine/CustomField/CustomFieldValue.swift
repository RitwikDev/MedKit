//
//  CustomFieldValue.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

import Foundation
import SwiftData

enum CustomFieldValueWrapper: Equatable, Hashable {
    case text(String)
    case date(Date)
    case list([String])
    case none
}

struct CustomFieldValue: Identifiable, Equatable, Hashable {
    let id: UUID
    let persistentIdentifier: PersistentIdentifier?
    
    var textValue: String?
    var dateValue: Date?
    var listValue: [String]?
    
    // UI layer representations of the relationships
    var definition: CustomField?
    
    init(
        id: UUID = UUID(),
        persistentIdentifier: PersistentIdentifier? = nil,
        textValue: String? = nil,
        dateValue: Date? = nil,
        textListValue: [String]? = nil,
        definition: CustomField? = nil
    ) {
        self.id = id
        self.persistentIdentifier = persistentIdentifier
        self.textValue = textValue
        self.dateValue = dateValue
        self.listValue = textListValue
        self.definition = definition
    }
    
    func getLabel() -> String {
        return self.definition?.label ?? ""
    }
    
    func getValue() -> CustomFieldValueWrapper {
        guard let type = self.definition?.dataType else {
            return .none
        }
        
        switch type {
        case .text:
            return .text(self.textValue ?? "")
        case .date:
            return .date(self.dateValue ?? .now)
        case .list:
            return .list(self.listValue ?? [])
        }
    }
}
