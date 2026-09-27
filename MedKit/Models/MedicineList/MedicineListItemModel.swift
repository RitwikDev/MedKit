//
//  MedicineListItemModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation

struct MedicineListItemModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let strengthAmount: Float?
    let strengthUnit: String?
    let stock: StockModel?
    let dosage: DosageModel?
    let expiryDate: Date?
    let tags: [Tag]
    let isOnShoppingList: Bool
    let isShared: Bool
    
    var isExpiringSoon: Bool {
        guard let expiryDate = self.expiryDate else { return false }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfExpiry = calendar.startOfDay(for: expiryDate)

        let daysToExpiration = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry).day ?? Int.max

        return daysToExpiration <= 7
    }
    
    var isRunningOutOfStock: Bool {
        guard let stock = self.stock else { return false }
        if (stock.quantity == 0) {
            return true
        }
        
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfEndDate = calendar.startOfDay(for: stock.endDate)
        let daysToStockout = calendar.dateComponents([.day], from: startOfToday, to: startOfEndDate).day ?? Int.max

        return daysToStockout <= 7
    }
}
