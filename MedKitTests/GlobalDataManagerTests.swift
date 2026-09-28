import Testing
import Foundation
import CoreData
@testable import MedKit

@Suite
@MainActor
struct GlobalDataManagerTests {
    
    @Test
    func fetchTags_emptyInitially() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let globalManager = GlobalDataManager.createForTesting(context: pc.container.viewContext)
        
        let tags = try globalManager.fetchAllTags()
        #expect(tags.isEmpty)
    }
    
    @Test
    func deleteTag() throws {
        let pc = PersistenceController.createForTesting(inMemory: true)
        let context = pc.container.viewContext
        let globalManager = GlobalDataManager.createForTesting(context: context)
        
        let entity = TagEntity(context: context)
        let tagId = UUID()
        entity.id = tagId
        entity.value = "Emergency"
        try context.save()
        
        let tags = try globalManager.fetchAllTags()
        #expect(tags.count == 1)
        
        // Delete it
        try globalManager.deleteTag(id: tagId)
        
        let tagsAfter = try globalManager.fetchAllTags()
        #expect(tagsAfter.isEmpty)
    }
}
