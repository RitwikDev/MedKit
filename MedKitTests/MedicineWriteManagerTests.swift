import Testing
import Foundation
import CoreData
@testable import MedKit

@Suite
@MainActor
struct MedicineWriteManagerTests {
    
    @Test
    func saveMedicine() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        let readManager = MedicineReadManager.createForTesting(context: context)
        
        let medId = UUID()
        let med = Medicine(id: medId, name: "Ibuprofen", tags: [], customFields: [], doseLogs: [])
        
        // Save the medicine
        try writeManager.save(med)
        
        // Fetch to verify
        let fetchedMed = try readManager.fetchById(medId)
        #expect(fetchedMed.name == "Ibuprofen")
    }
    
    @Test
    func deleteMedicine() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        let readManager = MedicineReadManager.createForTesting(context: context)
        
        let medId = UUID()
        let med = Medicine(id: medId, name: "TestMed", tags: [], customFields: [], doseLogs: [])
        try writeManager.save(med)
        
        // Ensure it exists
        _ = try readManager.fetchById(medId)
        
        // Delete it
        try writeManager.deleteMedicine(id: medId)
        
        let deletedMed = try readManager.fetchById(medId)
        #expect(deletedMed.name == "")
    }
    
    @Test
    func deleteAllMedicines() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let writeManager = MedicineWriteManager.createForTesting(context: context)
        let readManager = MedicineReadManager.createForTesting(context: context)
        
        let med1Id = UUID()
        let med2Id = UUID()
        
        try writeManager.save(Medicine(id: med1Id, name: "Med1", tags: [], customFields: [], doseLogs: []))
        try writeManager.save(Medicine(id: med2Id, name: "Med2", tags: [], customFields: [], doseLogs: []))
        
        try writeManager.deleteAllMedicines()
        
        let blankMed1 = try readManager.fetchById(med1Id)
        #expect(blankMed1.name == "")
    }
}
