//
//  Ingredient.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

struct Ingredient: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var strengthAmount: Float?
    var strengthUnit: String?
    
    init(
        id: UUID = UUID(),
        name: String = "",
        strengthAmount: Float? = nil,
        strengthUnit: String? = nil
    ) {
        self.id = id
        self.name = name
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
    }
}
