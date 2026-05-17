//
//  MedicineModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class MedicineModel: Codable {
    var name: String
    
    var quantity: Float
    
    var manufacturedDate: Date
    
    var expiryDate: Date
    
    @Relationship(deleteRule: .cascade)
    var strength: StrengthModel?
    
    @Relationship(deleteRule: .cascade)
    var compositions: [CompositionModel]
    
    @Relationship(deleteRule: .cascade)
    var customFields: [MedicineCustomFieldModel]
    
    var tags: [String]
    
    init(
        name: String = "",
        quantity: Float = 0,
        manufacturedDate: Date = .now,
        expiryDate: Date = .now,
        strength: StrengthModel? = nil,
        compositions: [CompositionModel] = [],
        customFields: [MedicineCustomFieldModel] = [],
        tags: [String] = [],
    ) {
        self.name = name
        self.quantity = quantity
        self.manufacturedDate = manufacturedDate
        self.expiryDate = expiryDate
        self.strength = strength
        self.compositions = compositions
        self.customFields = customFields
        self.tags = tags
    }
    
    enum CodingKeys: String, CodingKey {
        case name, quantity, manufacturedDate, expiryDate, strength, compositions, customFields, tags
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Float.self, forKey: .quantity)
        manufacturedDate = try container.decode(Date.self, forKey: .manufacturedDate)
        expiryDate = try container.decode(Date.self, forKey: .expiryDate)
        strength = try container.decodeIfPresent(StrengthModel.self, forKey: .strength)
        compositions = try container.decode([CompositionModel].self, forKey: .compositions)
        customFields = try container.decode([MedicineCustomFieldModel].self, forKey: .customFields)
        tags = try container.decode([String].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(manufacturedDate, forKey: .manufacturedDate)
        try container.encode(expiryDate, forKey: .expiryDate)
        try container.encodeIfPresent(strength, forKey: .strength)
        try container.encode(compositions, forKey: .compositions)
        try container.encode(customFields, forKey: .customFields)
        try container.encode(tags, forKey: .tags)
    }
    
    func getJsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(self),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return "{}"
    }
}
