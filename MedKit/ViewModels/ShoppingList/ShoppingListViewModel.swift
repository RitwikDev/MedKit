//
//  ShoppingListViewModel.swift
//  MedKit
//

import Foundation
import Observation

@Observable
class ShoppingListViewModel {
    var items: [Medicine] = []
    var errorMessage: String? = nil
    
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
            errorMessage = AppError.shoppingListUpdateFailed.errorDescription
        }
    }
    
    func removeFromShoppingList(at offsets: IndexSet) {
        for index in offsets {
            var medicine = items[index]
            medicine.isOnShoppingList = false
            do {
                try writeManager.save(medicine)
            } catch {
                errorMessage = AppError.shoppingListUpdateFailed.errorDescription
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
                errorMessage = AppError.shoppingListUpdateFailed.errorDescription
            }
        }
        fetchShoppingList()
    }
}
