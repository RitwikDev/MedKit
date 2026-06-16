//
//  Tag.swift
//  MedKit
//
//  Created by Rishik Dev on 23/05/26.
//

import Foundation
import SwiftData

struct Tag: Identifiable, Equatable, Hashable {
    let id: UUID
    let persistentIdentifier: PersistentIdentifier?
    var value: String
    
    init(id: UUID = UUID(), persistentIdentifier: PersistentIdentifier? = nil, value: String = "") {
        self.id = id
        self.persistentIdentifier = persistentIdentifier
        self.value = value
    }
}
