//
//  CompositionModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class CompositionModel {
    #Unique<CompositionModel>([\.name, \.strengthAmount, \.strengthUnit])

    var id: UUID
    var name: String
    var strengthAmount: Float?
    var strengthUnit: String?
    
    var medicine: MedicineModel?
    
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
    
    var fullName: String {
        if let amount = strengthAmount, let unit = strengthUnit {
            return "\(name) \(amount) \(unit)"
        } else {
            return name
        }
    }
    
    func copy() -> CompositionModel {
        CompositionModel(
            name: self.name,
            strengthAmount: self.strengthAmount,
            strengthUnit: self.strengthUnit
        )
    }
}
