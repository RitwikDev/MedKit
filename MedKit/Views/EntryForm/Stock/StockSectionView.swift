//
//  StockSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

import SwiftUI

struct StockSectionView: View {
    @Binding var stock: StockModel?
    
    @State private var draftQuantity: Float?
    @State private var draftUnit: String?
    
    var body: some View {
        QuantityUnitSectionView(
            sectionHeader: "Stock",
            quantityLabel: "Quantity",
            unitLabel: "Tablet/Drop...",
            error: "Invalid input",
            quantity: $draftQuantity,
            unit: $draftUnit,
            isValid: isValid,
        )
        .onAppear {
            draftQuantity = stock?.quantity
            draftUnit = stock?.unit
        }
        .onChange(of: draftQuantity) { _, newValue in
            updateStock(newQuantity: newValue, newUnit: draftUnit)
        }
        .onChange(of: draftUnit) { _, newValue in
            updateStock(newQuantity: draftQuantity, newUnit: newValue)
        }
    }
    
    private func isValid(quantity: Float?, unit: String?) -> Bool {
        let bothNil = quantity == nil && unit == nil
        let bothNotNil = (quantity != nil) && unit != nil
        
        return bothNil || bothNotNil
    }
        
    private func updateStock(newQuantity: Float?, newUnit: String?) {
        if let quantity = newQuantity, let unit = newUnit {
            stock = StockModel(quantity: quantity, unit: unit)
        } else {
            stock = nil
        }
    }
}

#Preview {
    StockSectionView(
        stock: .constant(.init())
    )
}
