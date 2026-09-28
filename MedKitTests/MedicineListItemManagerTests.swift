import Testing
import Foundation
import CoreData
@testable import MedKit

@Suite
@MainActor
struct MedicineListItemManagerTests {
    
    @Test
    func fetchMedicineList() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let listItemManager = MedicineListItemManager.createForTesting(context: context)
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        
        let med1 = Medicine(id: UUID(), name: "Zinc", tags: [], customFields: [], doseLogs: [])
        let med2 = Medicine(id: UUID(), name: "Apple", tags: [], customFields: [], doseLogs: [])
        try writeManager.save(med1)
        try writeManager.save(med2)
        
        // Fetch sorted by name A-Z
        let listStr = try listItemManager.fetchMedicineList(sortOn: .nameAscending)
        #expect(listStr.count == 2)
        #expect(listStr[0].name == "Apple")
        #expect(listStr[1].name == "Zinc")
        
        // Fetch sorted by name Z-A
        let listStrDesc = try listItemManager.fetchMedicineList(sortOn: .nameDescending)
        #expect(listStrDesc[0].name == "Zinc")
        #expect(listStrDesc[1].name == "Apple")
    }
}
