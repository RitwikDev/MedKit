//
//  TagModel.swift
//  MedKit
//
//  Created by Rishik Dev on 23/05/26.
//

import Foundation
import SwiftData

@Model
class TagModel: Codable {
    var value: String
    
    init(value: String = "") {
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    func copy() -> TagModel {
        TagModel(value: value)
    }
}
