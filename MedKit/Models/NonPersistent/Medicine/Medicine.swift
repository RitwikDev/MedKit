//
//  Medicine.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

struct Medicine: Identifiable, Equatable {
    // Stable, non-nil identifier dedicated strictly to SwiftUI rendering
    let id: UUID
    
    // The database passport token (nil indicates a brand new, unsaved draft)
    let persistentIdentifier: PersistentIdentifier?
    
    var name: String
    var quantity: Float
    var manufacturedDate: Date?
    var expiryDate: Date?
    var strengthAmount: Float?
    var strengthUnit: String?
    
    var composition: [Composition]
    var tags: [Tag]
    
    init(
        id: UUID = UUID(),
        persistentIdentifier: PersistentIdentifier? = nil,
        name: String = "",
        quantity: Float = 0,
        manufacturedDate: Date? = nil,
        expiryDate: Date? = nil,
        strengthAmount: Float? = nil,
        strengthUnit: String? = nil,
        composition: [Composition] = [],
        tags: [Tag] = []
    ) {
        self.id = id
        self.persistentIdentifier = persistentIdentifier
        self.name = name
        self.quantity = quantity
        self.manufacturedDate = manufacturedDate
        self.expiryDate = expiryDate
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
        self.composition = composition
        self.tags = tags
    }
}
