//
//  Composition.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

struct Composition: Identifiable, Equatable, Hashable {
    let id: UUID
    let persistentIdentifier: PersistentIdentifier?
    var name: String
    var strengthAmount: Float?
    var strengthUnit: String?
    
    init(
        id: UUID = UUID(),
        persistentIdentifier: PersistentIdentifier? = nil,
        name: String = "",
        strengthAmount: Float? = nil,
        strengthUnit: String? = nil
    ) {
        self.id = id
        self.persistentIdentifier = persistentIdentifier
        self.name = name
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
    }
}
