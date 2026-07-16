//
//  CodableMedicineModel.swift
//  MedKit
//
//  Created by Rishik Dev on 15/06/26.
//

import Foundation

struct CodableMedicineModel: Codable {
    var name: String
    var manufacturedDate: Date?
    var expiryDate: Date?
    var strengthAmount: Float?
    var strengthUnit: String?
    var composition: [CodableIngredientModel]
}

struct CodableIngredientModel: Codable {
    var name: String
    var strengthAmount: Float?
    var strengthUnit: String?
}
