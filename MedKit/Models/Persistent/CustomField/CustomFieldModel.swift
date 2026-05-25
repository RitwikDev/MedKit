//
//  CustomFieldModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class CustomFieldModel: Codable {
    var label: String
    var value: CustomFieldTypeEnum
    
    init(label: String = "", value: CustomFieldTypeEnum = .text("")) {
        self.label = label
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case label, value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        label = try container.decode(String.self, forKey: .label)
        value = try container.decode(CustomFieldTypeEnum.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(label, forKey: .label)
        try container.encode(value, forKey: .value)
    }
}
