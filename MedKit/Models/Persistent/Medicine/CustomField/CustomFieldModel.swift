//
//  CustomFieldModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//

/*
import Foundation
import SwiftData

@Model
final class CustomFieldModel {
    var label: String
    var rawDataType: String
    
    var dataType: CustomFieldDataType {
        get { CustomFieldDataType(rawValue: rawDataType) ?? .text }
        set { rawDataType = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \CustomFieldValueModel.definiion)
    var values: [CustomFieldValueModel] = []
    
    init(
        label: String = "",
        dataType: CustomFieldDataType = .text,
        values: [CustomFieldValueModel] = [],
    ) {
        self.label = label
        self.rawDataType = dataType.rawValue
        self.values = values
    }
    
    func copy() -> CustomFieldModel {
        return CustomFieldModel(
            label: self.label,
            dataType: self.dataType
        )
    }
}
*/
