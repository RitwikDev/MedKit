//
//  MedicineListItemManager.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import CoreData
import Foundation

class MedicineListItemManager {
    static let shared: MedicineListItemManager = .init()
    
    private let context: NSManagedObjectContext
    
    private init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    public func fetchMedicineList() throws -> [MedicineListItemModel] {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.name, ascending: true)]
        
        let entities = try context.fetch(request)
        
        return entities.map { mapMedicine(entity: $0) }
    }
    
    private func mapMedicine(entity: MedicineEntity) -> MedicineListItemModel {
        MedicineListItemModel(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            strengthAmount: entity.strengthAmount,
            strengthUnit: entity.strengthUnit,
            stock: StockModel.fromMedicineEntity(entity),
            expiryDate: entity.expiryDate ?? .now,
            tags: mapTags(medicineEntity: entity),
        )
    }
    
    private func mapTags(medicineEntity: MedicineEntity) -> [Tag] {
        let tagEntities = medicineEntity.tags as? Set<TagEntity> ?? []
        let tags = tagEntities.map {
            Tag(
                id: $0.id ?? UUID(),
                value: $0.value ?? ""
            )
        }.sorted { $0.value < $1.value }
        
        return tags
    }
}
