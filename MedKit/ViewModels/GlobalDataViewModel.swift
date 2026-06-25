import Foundation
import SwiftUI
import CoreData

/// Powers global autocomplete lists and pickers for shared data dictionaries.
@Observable
@MainActor
public final class GlobalDataViewModel {
    
    public var availableTags: [Tag] = []
    public var availableIngredients: [Ingredient] = []
    public var availableCustomFields: [CustomField] = []
    
    @ObservationIgnored
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchAllGlobalData()
    }
    
    /// Refreshes all global dictionary arrays.
    public func fetchAllGlobalData() {
        fetchTags()
        fetchIngredients()
        fetchCustomFields()
    }
    
    private func fetchTags() {
        let request: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TagEntity.value, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            self.availableTags = entities.map { Tag(id: $0.id ?? UUID(), value: $0.value ?? "") }
        } catch {
            print("Failed to fetch tags: \(error.localizedDescription)")
        }
    }
    
    private func fetchIngredients() {
        let request: NSFetchRequest<IngredientEntity> = IngredientEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \IngredientEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            
            // Map entities and filter out duplicate names to create a clean autocomplete list
            var uniqueIngredients: [Ingredient] = []
            var seenNames: Set<String> = []
            
            for entity in entities {
                let name = entity.name ?? ""
                let lowercasedName = name.lowercased()
                
                if !seenNames.contains(lowercasedName) && !name.isEmpty {
                    seenNames.insert(lowercasedName)
                    uniqueIngredients.append(
                        Ingredient(
                            id: entity.id ?? UUID(),
                            name: name,
                            strengthAmount: entity.strengthAmount > 0 ? entity.strengthAmount : nil,
                            strengthUnit: entity.strengthUnit
                        )
                    )
                }
            }
            
            self.availableIngredients = uniqueIngredients
        } catch {
            print("Failed to fetch ingredients: \(error.localizedDescription)")
        }
    }
    
    private func fetchCustomFields() {
        let request: NSFetchRequest<CustomFieldEntity> = CustomFieldEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CustomFieldEntity.label, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            self.availableCustomFields = entities.map { entity in
                CustomField(
                    id: entity.id ?? UUID(),
                    label: entity.label ?? "",
                    dataType: CustomFieldDataType(rawValue: entity.dataType ?? "") ?? .text
                )
            }
        } catch {
            print("Failed to fetch custom fields: \(error.localizedDescription)")
        }
    }
}