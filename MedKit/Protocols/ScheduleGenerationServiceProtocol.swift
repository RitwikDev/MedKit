import Foundation

protocol ScheduleGenerationServiceProtocol: Actor {
    func generateEvents(for targetMonth: Date, medicines: [CalendarMedicine], currentRecordName: String) async -> [Date: [CalendarEvent]]
}
