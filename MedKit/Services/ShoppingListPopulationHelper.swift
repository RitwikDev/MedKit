//
//  ShoppingListPopulationHelper.swift
//  MedKit
//

import Foundation

class ShoppingListPopulationHelper {
    static func shouldPopulate(stockEndDate: Date?, expiryDate: Date?, stockQuantity: Float? = nil) -> Bool {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: 7, to: Date()) else { return false }
        
        if let quantity = stockQuantity, quantity <= 0 {
            return true
        }

        if let end = stockEndDate, end != .distantFuture, end <= cutoffDate {
            return true
        }
        
        if let expiry = expiryDate, expiry <= cutoffDate {
            return true
        }
        
        return false
    }
    
    static func getReason(stockEndDate: Date?, expiryDate: Date?, stockQuantity: Float? = nil) -> [String] {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: 7, to: Date()) else { return ["Added to list"] }
        
        let isStockout = (stockQuantity != nil && stockQuantity! <= 0)
        let stockEmpty = isStockout || (stockEndDate != nil && stockEndDate != .distantFuture && stockEndDate! <= cutoffDate)
        let stockReason = isStockout ? "Stockout" : "Stock running low"
        let expiring = (expiryDate != nil && expiryDate! <= cutoffDate)
        
        if stockEmpty && expiring {
            if let expiryDate, expiryDate < .now {
                return [stockReason, "Expired"]
            }
            
            return [stockReason, "Expiring soon"]
        } else if stockEmpty {
            return [stockReason]
        } else if expiring {
            if let expiryDate, expiryDate < .now {
                return ["Expired"]
            }
            return ["Expiring soon"]
        } else {
            return ["Manually added"]
        }
    }
}
