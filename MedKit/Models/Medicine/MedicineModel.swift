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
    
    var manufacturedDate: Date?
    
    var expiryDate: Date?
    
    @Relationship(deleteRule: .cascade)
    var strength: StrengthModel?
    
    @Relationship(deleteRule: .cascade)
    var composition: [CompositionModel]
    
    @Relationship(deleteRule: .cascade)
    var customFields: [CustomFieldModel]
    
    var tags: [String]
    
    init(
        name: String = "",
        quantity: Float = 0,
        manufacturedDate: Date? = nil,
        expiryDate: Date? = nil,
        strength: StrengthModel? = nil,
        composition: [CompositionModel] = [],
        customFields: [CustomFieldModel] = [],
        tags: [String] = [],
    ) {
        self.name = name
        self.quantity = quantity
        self.manufacturedDate = manufacturedDate
        self.expiryDate = expiryDate
        self.strength = strength
        self.composition = composition
        self.customFields = customFields
        self.tags = tags
    }
    
    enum CodingKeys: String, CodingKey {
        case name, quantity, manufacturedDate, expiryDate, strength, composition, customFields, tags
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Float.self, forKey: .quantity)
        manufacturedDate = try container.decodeIfPresent(Date.self, forKey: .manufacturedDate)
        expiryDate = try container.decodeIfPresent(Date.self, forKey: .expiryDate)
        strength = try container.decodeIfPresent(StrengthModel.self, forKey: .strength)
        composition = try container.decode([CompositionModel].self, forKey: .composition)
        customFields = try container.decode([CustomFieldModel].self, forKey: .customFields)
        tags = try container.decode([String].self, forKey: .tags)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encodeIfPresent(manufacturedDate, forKey: .manufacturedDate)
        try container.encodeIfPresent(expiryDate, forKey: .expiryDate)
        try container.encodeIfPresent(strength, forKey: .strength)
        try container.encode(composition, forKey: .composition)
        try container.encode(customFields, forKey: .customFields)
        try container.encode(tags, forKey: .tags)
    }
    
    func copy() -> MedicineModel {
        MedicineModel(name: name,
                      quantity: quantity,
                      manufacturedDate: manufacturedDate,
                      expiryDate: expiryDate,
                      strength: strength,
                      composition: composition,
                      customFields: customFields,
                      tags: tags)
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
