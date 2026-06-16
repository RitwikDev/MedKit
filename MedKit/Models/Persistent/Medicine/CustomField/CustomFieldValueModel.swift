//
//  CustomFieldValueModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

import Foundation
import SwiftData

@Model
final class CustomFieldValueModel {
    var textValue: String?
    var dateValue: Date?
    var textListValue: [String]?
    
    var definiion: CustomFieldModel?
    var medicine: MedicineModel?
    
    init(
        textValue: String? = nil,
        dateValue: Date? = nil,
        textListValue: [String]? = nil,
        definition: CustomFieldModel? = nil,
        medicine: MedicineModel? = nil
    ) {
        self.textValue = textValue
        self.dateValue = dateValue
        self.textListValue = textListValue
        self.definiion = definition
        self.medicine = medicine
    }
    
    func copy() -> CustomFieldValueModel {
        return CustomFieldValueModel(
            textValue: self.textValue,
            dateValue: self.dateValue,
            textListValue: self.textListValue,
            definition: self.definiion,
            medicine: nil,
        )
    }
}
