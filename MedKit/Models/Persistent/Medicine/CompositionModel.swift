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

    var name: String
    var strengthAmount: Float
    var strengthUnit: String
    
    var medicine: MedicineModel?
    
    init(name: String = "", strengthAmount: Float = 0, strengthUnit: String = "") {
        self.name = name
        self.strengthAmount = strengthAmount
        self.strengthUnit = strengthUnit
    }
    
    func getFullName() -> String {
        if strengthAmount > 0 {
            return "\(name) \(strengthAmount) \(strengthUnit)"
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
