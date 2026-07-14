//
//  MedicineViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 19/06/26.
//

import SwiftUI

@Observable
class MedicineViewModel {
    var medicines: [MedicineListItemModel] = []
    var errorMessage: String? = nil
    
    init() {
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
    func fetchAllMedicines() {
        do {
            self.medicines = try MedicineListItemManager.shared.fetchMedicineList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getById(_ id: UUID) -> Medicine? {
        do {
            return try MedicineReadManager.shared.fetchById(id)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    func deleteMedicine(at offsets: IndexSet) {
        do {
            for index in offsets {
                let medicineId = medicines[index].id
                try MedicineWriteManager.shared.deleteMedicine(id: medicineId)
            }
            fetchAllMedicines()
        } catch {
            errorMessage = error.localizedDescription
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
}
