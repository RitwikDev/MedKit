//
//  ShoppingListViewModel.swift
//  MedKit
//

import Foundation
import Observation

@Observable
class ShoppingListViewModel {
    var items: [Medicine] = []
    
    private let readManager: MedicineReadManagerProtocol
    private let writeManager: MedicineWriteManagerProtocol

    init(readManager: MedicineReadManagerProtocol = MedicineReadManager.shared,
         writeManager: MedicineWriteManagerProtocol = MedicineWriteManager.shared) {
        self.readManager = readManager
        self.writeManager = writeManager
    }
    
    func fetchShoppingList() {
        do {
            items = try readManager.fetchShoppingList()
        } catch {
            print("Failed to fetch shopping list")
        }
    }
    
    func removeFromShoppingList(at offsets: IndexSet) {
        for index in offsets {
            var medicine = items[index]
            medicine.isOnShoppingList = false
            do {
                try writeManager.save(medicine)
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
                try writeManager.save(medicine)
            } catch {
                print("Failed to clear shopping list")
            }
        }
        fetchShoppingList()
    }
}
