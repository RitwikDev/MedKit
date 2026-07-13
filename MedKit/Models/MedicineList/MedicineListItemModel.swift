//
//  MedicineListItemModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation

struct MedicineListItemModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let strengthAmount: Float?
    let strengthUnit: String?
    let stockQuantity: Float?
    let expiryDate: Date?
    let tags: [Tag]
}
