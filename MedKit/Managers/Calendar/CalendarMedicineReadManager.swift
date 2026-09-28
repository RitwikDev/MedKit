//
//  CalendarMedicineReadManager.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import CoreData
import Foundation

class CalendarMedicineReadManager: CalendarMedicineReadManagerProtocol {
    static let shared: CalendarMedicineReadManager = .init()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    public func getMedicines() throws -> [CalendarMedicine] {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        
        let entities = try context.fetch(request)
        
        return entities.map { mapMedicine(entity: $0) }
    }
    
    private func mapMedicine(entity: MedicineEntity) -> CalendarMedicine {
        let doseLogEntities = entity.doseLogs as? Set<DoseLogEntity> ?? []
        let doseLogs = doseLogEntities.compactMap { DoseLogModel.fromEntity($0) }
        
        return CalendarMedicine(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            expiryDate: entity.expiryDate,
            dosage: DosageModel.fromMedicineEntity(entity),
            stock: StockModel.fromMedicineEntity(entity),
            doseLogs: doseLogs
        )
    }

    #if DEBUG
    /// Creates a fresh instance specifically for testing with an in-memory context.
    /// Do not use in production code; use `.shared` instead.
    static func createForTesting(context: NSManagedObjectContext) -> CalendarMedicineReadManager {
        return CalendarMedicineReadManager(context: context)
    }
    #endif
}
