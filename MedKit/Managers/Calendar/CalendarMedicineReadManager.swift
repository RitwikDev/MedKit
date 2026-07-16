//
//  CalendarMedicineReadManager.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import CoreData
import Foundation

class CalendarMedicineReadManager {
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
        CalendarMedicine(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            expiryDate: entity.expiryDate ?? .now,
            schedule: Schedule.fromMedicineEntity(entity),
            doseQuantity: entity.doseQuantity,
            stock: StockModel.fromMedicineEntity(entity),
        )
    }
}
