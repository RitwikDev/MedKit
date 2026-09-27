//
//  MedicineViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 19/06/26.
//

import SwiftUI

@Observable
@MainActor
class MedicineViewModel {
    var medicines: [MedicineListItemModel] = []
    var errorMessage: String? = nil
    
    // Injectable dependencies
    private let listItemManager: MedicineListItemManagerProtocol
    private let readManager: MedicineReadManagerProtocol
    
    init(
        listItemManager: MedicineListItemManagerProtocol = MedicineListItemManager.shared,
        readManager: MedicineReadManagerProtocol = MedicineReadManager.shared
    ) {
        self.listItemManager = listItemManager
        self.readManager = readManager
        fetchAllMedicines()
        
        Task {
            // This loop quietly listens in the background forever
            for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
                // When CloudKit updates the database, safely refresh the UI on the main thread
                await MainActor.run {
                    self.fetchAllMedicines()
                }
            }
        }
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    func fetchAllMedicines(
        sortOn: MedicineListSortOptionsEnum = .nameAscending
    ) {
        do {
            self.medicines = try listItemManager.fetchMedicineList(sortOn: sortOn)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Returns the Medicine corresponding to the given id.
    ///
    /// - Parameter id: The UUID of the medicine to be fetched.
    /// - Returns: The Medicine object corresponding to the given id.
    /// 
    func toggleShoppingList(for medicineId: UUID) {
        do {
            if var medicine = getById(medicineId) {
                medicine.isOnShoppingList.toggle()
                try MedicineWriteManager.shared.save(medicine)
                fetchAllMedicines()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }


    func getById(_ id: UUID) -> Medicine? {
        do {
            return try readManager.fetchById(id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    func deleteMedicine(at offsets: IndexSet) {
        Task {
            do {
                for index in offsets {
                    let medicineId = medicines[index].id
                    
                    await NotificationManager.shared.removePendingNotificationRequests(for: medicineId)
                    
                    try MedicineWriteManager.shared.deleteMedicine(id: medicineId)
                }
                fetchAllMedicines()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// Asks the Manager to delete all medicines.
    func deleteAllMedicines() {
        do {
            try MedicineWriteManager.shared.deleteAllMedicines()
            fetchAllMedicines()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Asks the Manager to update the stock of the given medicine
    ///
    /// - Parameters:
    ///   - medicineId: The id of the medicine whose stock needs to be updated
    ///   - quantity: The new quantity of the medicine
    ///   - dosage: The dosage object of the medicine
    ///   
    func updateStockQuantity(
        medicineId: UUID,
        quantity: Float,
        dosage: DosageModel?
    ) {
        listItemManager.updateStockQuantity(
            medicineId: medicineId,
            quantity: quantity,
            dosage: dosage
        )
    }
}
