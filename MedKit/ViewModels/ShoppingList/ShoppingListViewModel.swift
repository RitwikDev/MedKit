//
//  ShoppingListViewModel.swift
//  MedKit
//

import Foundation
import Observation

@Observable
class ShoppingListViewModel {
    var items: [Medicine] = []
    
    func fetchShoppingList() {
        do {
            items = try MedicineReadManager.shared.fetchShoppingList()
        } catch {
            print("Failed to fetch shopping list")
        }
    }
    
    func removeFromShoppingList(at offsets: IndexSet) {
        for index in offsets {
            var medicine = items[index]
            medicine.isOnShoppingList = false
            do {
                try MedicineWriteManager.shared.save(medicine)
            } catch {
                print("Failed to remove item")
            }
        }
        fetchShoppingList()
    }
    
    func clearShoppingList() {
        for var medicine in items {
            medicine.isOnShoppingList = false
            do {
                try MedicineWriteManager.shared.save(medicine)
            } catch {
                print("Failed to clear shopping list")
            }
        }
        fetchShoppingList()
    }
}
