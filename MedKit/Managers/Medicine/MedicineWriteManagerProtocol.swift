//
//  MedicineWriteManagerProtocol.swift
//  MedKit
//
//  Created by Auto.
//

import CloudKit
import CoreData
import Foundation

protocol MedicineWriteManagerProtocol {
    func save(_ medicine: Medicine) throws
    func deleteMedicine(id: UUID) throws
    func deleteAllMedicines() throws
    @MainActor func fetchOrCreateShare(for medicine: Medicine) async throws -> (CKShare, CKContainer)
}
