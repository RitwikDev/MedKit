import Testing
import Foundation
import CoreData
@testable import MedKit

@Suite
@MainActor
struct CalendarMedicineReadManagerTests {
    
    @Test
    func getMedicines() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let calendarReadManager = CalendarMedicineReadManager.createForTesting(context: context)
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        
        let med = Medicine(id: UUID(), name: "CalMed", tags: [], customFields: [], doseLogs: [])
        try writeManager.save(med)
        
        let meds = try calendarReadManager.getMedicines()
        #expect(meds.count == 1)
        #expect(meds.first?.name == "CalMed")
    }
}
