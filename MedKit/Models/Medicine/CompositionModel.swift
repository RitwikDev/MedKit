//
//  CompositionModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class CompositionModel: Codable {
    var name: String
    var strength: StrengthModel?
    
    init(name: String = "", strength: StrengthModel? = nil) {
        self.name = name
        self.strength = strength
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case strength
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        strength = try container.decodeIfPresent(StrengthModel.self, forKey: .strength)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(strength, forKey: .strength)
    }
    
    func getFullName() -> String {
        if let strength = strength {
            return "\(name) \(strength.amount) \(strength.unit)"
        } else {
            return name
        }
    }
    
    func copy() -> CompositionModel {
        CompositionModel(name: name, strength: strength)
    }
}
