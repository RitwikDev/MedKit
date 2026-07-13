//
//  Medicine.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

struct Medicine: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var stockQuantity: Float?
    var stockUnit: String?
    var manufacturedDate: Date?
    var expiryDate: Date?
    var strengthAmount: Float?
    var strengthUnit: String?
    var doseQuantity: Float?
    
    var composition: [Ingredient]
    var schedule: Schedule?
    var tags: [Tag]
    var customFields: [CustomFieldValue]
    
    init(
        id: UUID = UUID(),
        name: String = "",
        stockQuantity: Float? = nil,
        stockUnit: String? = nil,
        manufacturedDate: Date? = nil,
        expiryDate: Date? = nil,
        strengthAmount: Float? = nil,
        strengthUnit: String? = nil,
        doseQuantity: Float? = nil,
        composition: [Ingredient] = [],
        schedule: Schedule? = nil,
        tags: [Tag] = [],
        customFields: [CustomFieldValue] = [],
    ) {
        self.id = id
        self.name = name
        self.stockQuantity = stockQuantity
        self.stockUnit = stockUnit
        self.manufacturedDate = manufacturedDate
        self.expiryDate = expiryDate
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
        self.doseQuantity = doseQuantity
        self.composition = composition
        self.schedule = schedule
        self.tags = tags
        self.customFields = customFields
    }
    
    public func getCustomFieldsSortedByLabel() -> [CustomFieldValue] {
        self.customFields.sorted { $0.getLabel().localizedCaseInsensitiveCompare($1.getLabel()) == .orderedAscending }
    }
}
