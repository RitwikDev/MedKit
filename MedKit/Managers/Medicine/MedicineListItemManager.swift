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
    
    public func fetchMedicineList(
        sortOn: MedicineListSortOptionsEnum = .nameAscending,
    ) throws -> [MedicineListItemModel] {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        
        switch sortOn {
        case .nameAscending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.name, ascending: true)]
        case .nameDescending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.name, ascending: false)]
        case .expiryAscending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.expiryDate, ascending: true)]
        case .expiryDescending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.expiryDate, ascending: false)]
        case .stockAscending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.stock?.quantity, ascending: true)]
        case .stockDescending:
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineEntity.stock?.quantity, ascending: false)]
        }
        
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
            dosage: DosageModel.fromMedicineEntity(entity),
            expiryDate: entity.expiryDate,
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
    
    public func updateStockQuantity(
        medicineId: UUID,
        quantity: Float,
        dosage: DosageModel?,
    ) -> Void {
        let request: NSFetchRequest<MedicineEntity> = MedicineEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", medicineId as CVarArg)
        
        do {
            let results = try context.fetch(request)
            guard let entity = results.first, let stockEntity = entity.stock else {
                return
            }
            
            let stock: StockModel = .init(
                id: stockEntity.id ?? UUID(),
                quantity: quantity,
                unit: stockEntity.unit ?? "",
                endDate: stockEntity.endDate ?? .distantFuture,
            )
            
            if let endDate = MedicineStockEndDateCalculator.calculate(
                stock: stock,
                dosage: dosage,
            ) {
                stockEntity.endDate = endDate
            } else {
                stockEntity.endDate = .distantFuture
            }
            
            stockEntity.quantity = quantity
            entity.stock = stockEntity
            
            // Populate shopping list if within 7 days
            if ShoppingListPopulationHelper.shouldPopulate(stockEndDate: stockEntity.endDate, expiryDate: entity.expiryDate) {
                entity.isOnShoppingList = true
            } else {
                entity.isOnShoppingList = false
            }
            
            if (context.hasChanges) {
                try context.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NotificationManager.dataDidChangeNotification, object: nil)
                }
            }
        } catch {
            context.rollback()
        }
    }
}
