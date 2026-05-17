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
    var strength: StrengthModel
    
    init(name: String = "", strength: StrengthModel = StrengthModel()) {
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
        strength = try container.decode(StrengthModel.self, forKey: .strength)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(strength, forKey: .strength)
    }
}
