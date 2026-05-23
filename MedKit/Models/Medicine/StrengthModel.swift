//
//  StrengthModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class StrengthModel: Codable {
    var amount: Float
    var unit: String
    
    init(amount: Float = 0, unit: String = "") {
        self.amount = amount
        self.unit = unit
    }
    
    enum CodingKeys: String, CodingKey {
            case amount
            case unit
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        amount = try container.decode(Float.self, forKey: .amount)
        unit = try container.decode(String.self, forKey: .unit)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(amount, forKey: .amount)
        try container.encode(unit, forKey: .unit)
    }
}
