//
//  MedicineCustomFieldValueTypeEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import Foundation

enum MedicineCustomFieldValueTypeEnum: Codable {
    case number(Float)
    case text(String)
    case date(Date)
    case list([String])
}
