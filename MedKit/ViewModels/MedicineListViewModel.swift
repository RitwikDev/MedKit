import SwiftUI

/// ViewModel responsible for managing the display list of all medicines.
@Observable
@MainActor
public final class MedicineListViewModel {
    
    /// The array of medicines to display in the UI.
    public var medicines: [Medicine] = []
    
    public init() {
        refreshData()
    }
    
    /// Asks the Manager to fetch the latest data from the database.
    public func refreshData() {
        self.medicines = MedicineManager.shared.fetchAllMedicines()
    }
    
    /// Asks the Manager to delete a specific record, then refreshes the UI.
    /// - Parameter offsets: The index set from a SwiftUI `onDelete` modifier.
    public func deleteMedicine(at offsets: IndexSet) {
        for index in offsets {
            let medicineId = medicines[index].id
            MedicineManager.shared.delete(by: medicineId)
        }
        refreshData()
    }
}