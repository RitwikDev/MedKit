//
//  MedicineCustomFieldModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation
import SwiftData

@Model
class MedicineCustomFieldModel: Codable {
    var customFieldId: UUID // ties to CustomFieldModel
    var value: MedicineCustomFieldValueTypeEnum
    
    init(customFieldId: UUID = UUID(), value: MedicineCustomFieldValueTypeEnum = .text("")) {
        self.customFieldId = customFieldId
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case customFieldId
        case value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        customFieldId = try container.decode(UUID.self, forKey: .customFieldId)
        value = try container.decode(MedicineCustomFieldValueTypeEnum.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(customFieldId, forKey: .customFieldId)
        try container.encode(value, forKey: .value)
    }
}
