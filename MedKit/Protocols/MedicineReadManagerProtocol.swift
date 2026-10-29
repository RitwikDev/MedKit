//
//  MedicineReadManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import Foundation

protocol MedicineReadManagerProtocol {
    func fetchShoppingList() throws -> [Medicine]
    func fetchById(_ id: UUID) throws -> Medicine
    func fetchAll() throws -> [Medicine]
}

extension MedicineReadManagerProtocol {
    func fetchAll() throws -> [Medicine] { return [] }
}
