import Testing
import Foundation
import CoreData
@testable import MedKit

@Suite
@MainActor
struct MedicineReadManagerTests {
    
    @Test
    func fetchShoppingList() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        let readManager = MedicineReadManager.createForTesting(context: context)
        
        // Med on shopping list
        var med1 = Medicine(id: UUID(), name: "BuyMe", tags: [], customFields: [], doseLogs: [])
        med1.isOnShoppingList = true
        try writeManager.save(med1)
        
        // Med not on shopping list
        var med2 = Medicine(id: UUID(), name: "HaveMe", tags: [], customFields: [], doseLogs: [])
        med2.isOnShoppingList = false
        try writeManager.save(med2)
        
        let shoppingList = try readManager.fetchShoppingList()
        #expect(shoppingList.count == 1)
        #expect(shoppingList.first?.name == "BuyMe")
    }
    
    @Test
    func fetchById_notFound_returnsBlankMedicine() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let readManager = MedicineReadManager.createForTesting(context: context)
        
        // App currently generates an empty struct entity when it isn't found
        let blankMed = try readManager.fetchById(UUID())
        #expect(blankMed.name == "")
    }
}
