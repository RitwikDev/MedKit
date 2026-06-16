//
//  MedicineModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class MedicineModel {
    var name: String
    var quantity: Float
    var manufacturedDate: Date?
    var expiryDate: Date?
    var strengthAmount: Float?
    var strengthUnit: String?
    
    @Relationship(deleteRule: .cascade, inverse: \CompositionModel.medicine)
    var composition: [CompositionModel] = []
    
    var schedule: ScheduleModel?
    
    @Relationship(deleteRule: .nullify, inverse: \TagModel.medicines)
    var tags: [TagModel] = []
    
    @Relationship(deleteRule: .cascade, inverse: \CustomFieldValueModel.medicine)
    var customFields: [CustomFieldValueModel] = []
    
    init(
        name: String = "",
        quantity: Float = 0,
        manufacturedDate: Date? = nil,
        expiryDate: Date? = nil,
        strengthAmount: Float? = nil,
        strengthUnit: String? = nil,
        composition: [CompositionModel] = [],
        schedule: ScheduleModel? = nil,
        tags: [TagModel] = [],
        customFields: [CustomFieldValueModel] = [],
    ) {
        self.name = name
        self.quantity = quantity
        self.manufacturedDate = manufacturedDate
        self.expiryDate = expiryDate
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
        self.composition = composition
        self.schedule = schedule
        self.tags = tags
        self.customFields = customFields
    }
    
    func copy() -> MedicineModel {
        let copiedComposition = composition.map { $0.copy() }
        let copiedCustomFields = customFields.map { $0.copy() }
        
        return MedicineModel(
            name: self.name,
            quantity: self.quantity,
            manufacturedDate: self.manufacturedDate,
            expiryDate: self.expiryDate,
            strengthAmount: self.strengthAmount,
            strengthUnit: self.strengthUnit,
            composition: copiedComposition,
            schedule: schedule,
            tags: self.tags,
            customFields: copiedCustomFields,
        )
    }
}
