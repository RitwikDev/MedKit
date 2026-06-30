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
    case documents([Document])
    case none
}

enum DocumentType: String {
    case photo, document
}

struct Document: Identifiable, Comparable, Hashable {
    let id: UUID
    let name: String
    let documentExtension: String
    let documentData: Data
    let documentType: DocumentType
    
    init(id: UUID = UUID(), name: String, documentExtension: String, documentData: Data, documentType: DocumentType) {
        self.id = id
        self.name = name
        self.documentExtension = documentExtension
        self.documentData = documentData
        self.documentType = documentType
    }
    
    static func < (lhs: Document, rhs: Document) -> Bool {
        lhs.name < rhs.name
    }
}

struct CustomFieldValue: Identifiable, Equatable, Hashable, Comparable {
    let id: UUID
    var textValue: String?
    var dateValue: Date?
    var listValue: [String]?
    var documentValue: [Document]?
    
    // UI layer representations of the relationships
    var definition: CustomField?
    
    init(
        id: UUID = UUID(),
        textValue: String? = nil,
        dateValue: Date? = nil,
        textListValue: [String]? = nil,
        documentValue: [Document]? = nil,
        definition: CustomField? = nil
    ) {
        self.id = id
        self.textValue = textValue
        self.dateValue = dateValue
        self.listValue = textListValue
        self.documentValue = documentValue
        self.definition = definition
    }
    
    static func < (lhs: CustomFieldValue, rhs: CustomFieldValue) -> Bool {
        lhs.definition?.label ?? "" < rhs.definition?.label ?? ""
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
        case .documents:
            return .documents(self.documentValue ?? [])
        }
    }
}
