//
//  MedicineListItemManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import Foundation

protocol MedicineListItemManagerProtocol {
    func fetchMedicineList(sortOn: MedicineListSortOptionsEnum) throws -> [MedicineListItemModel]
    func updateStockQuantity(medicineId: UUID, quantity: Float, dosage: DosageModel?)
}
