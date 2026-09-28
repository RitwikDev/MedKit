//
//  GlobalDataManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import Foundation

protocol GlobalDataManagerProtocol {
    func fetchAllTags() throws -> [Tag]
    func fetchAllIngredients() throws -> [Ingredient]
    func fetchAllCustomFields() throws -> [CustomField]
    func fetchAllStrengthUnits() throws -> Set<String>
    func fetchAllStockTypes() throws -> Set<String>
    func deleteTag(id: UUID) throws
    func deleteIngredient(id: UUID) throws
    func deleteCustomField(id: UUID) throws
    func deleteAllMedicines() throws
    func deleteAllTags() throws
    func deleteAllIngredients() throws
    func deleteAllCustomFields() throws
    func fetchCurrentRecordName() async -> String?
}
