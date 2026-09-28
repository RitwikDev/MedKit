import Testing
import Foundation
@testable import MedKit

@Suite
struct CalendarUIHelperTests {
    @Test
    func generateDays() {
        let days = CalendarUIHelper.generateDays(for: Date())
        #expect(days.count > 28)
    }
}
