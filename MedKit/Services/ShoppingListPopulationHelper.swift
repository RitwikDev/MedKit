//
//  ShoppingListPopulationHelper.swift
//  MedKit
//

import Foundation

class ShoppingListPopulationHelper {
    static func shouldPopulate(stockEndDate: Date?, expiryDate: Date?) -> Bool {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: 7, to: Date()) else { return false }
        
        if let end = stockEndDate, end != .distantFuture, end <= cutoffDate {
            return true
        }
        
        if let expiry = expiryDate, expiry <= cutoffDate {
            return true
        }
        
        return false
    }
    
    static func getReason(stockEndDate: Date?, expiryDate: Date?) -> [String] {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: 7, to: Date()) else { return ["Added to list"] }
        
        let stockEmpty = (stockEndDate != nil && stockEndDate != .distantFuture && stockEndDate! <= cutoffDate)
        let expiring = (expiryDate != nil && expiryDate! <= cutoffDate)
        
        if stockEmpty && expiring {
            if let expiryDate, expiryDate < .now {
                return ["Stock running low", "Expired"]
            }
            
            return ["Stock running low", "Expiring soon"]
        } else if stockEmpty {
            return ["Stock running low"]
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
