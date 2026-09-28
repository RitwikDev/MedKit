//
//  MedicineWriteManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import CloudKit

protocol MedicineWriteManagerProtocol {
    func save(_ medicine: Medicine) throws
    func deleteMedicine(id: UUID) throws
    func deleteAllMedicines() throws
    @MainActor func fetchOrCreateShare(for medicine: Medicine) async throws -> (CKShare, CKContainer)
}
