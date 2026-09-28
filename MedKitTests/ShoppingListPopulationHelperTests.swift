import Testing
import Foundation
@testable import MedKit

@Suite
struct ShoppingListPopulationHelperTests {
    @Test
    func shouldPopulate_stockout() {
        let result = ShoppingListPopulationHelper.shouldPopulate(stockEndDate: nil, expiryDate: nil, stockQuantity: 0.0)
        #expect(result == true)
    }
    
    @Test
    func shouldPopulate_healthy() {
        let result = ShoppingListPopulationHelper.shouldPopulate(stockEndDate: .distantFuture, expiryDate: .distantFuture, stockQuantity: 10.0)
        #expect(result == false)
    }
}
