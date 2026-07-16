//
//  QuantityUnitSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct QuantityUnitSectionView: View {
    let sectionHeader: String
    var quantityLabel: String = "Quantity"
    let unitLabel: String
    var error: String = "Invalid input"
    
    @Binding var quantity: Float?
    @Binding var unit: String?
    var textColour: Color = .primary
    let isValid: (Float?, String?) -> Bool
    
    @State var quantityString: String = ""
    @State var unitString: String = ""
        
    var body: some View {
        Section(content: {
            VStack {
                TextField(quantityLabel, text: $quantityString)
                    .keyboardType(.decimalPad)
                    .onChange(of: quantityString) { oldValue, newValue in
                        handleQuantityChange(oldValue: oldValue, newValue: newValue)
                    }
                
                Divider()
                
                TextField(unitLabel, text: $unitString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: unitString) { oldValue, newValue in
                        unit = newValue.trimmedIsEmpty ? nil : newValue
                    }
            }
            .foregroundStyle(textColour)
            .onAppear(perform: handleChange)
            .onChange(of: [quantity, unit] as [AnyHashable]) {
                handleChange()
            }
        }, header: {
            Text(sectionHeader)
        }, footer: {
            if (!isValid(quantity, unit)) {
                Text(error)
                    .foregroundStyle(.red)
            }
        })
    }
    
    private func handleChange() {
        if let amount = quantity {
            quantityString = String(format: "%g", amount)
        } else {
            quantityString = ""
        }
        
        unitString = unit ?? ""
    }
    
    private func handleQuantityChange(oldValue: String, newValue: String) {
        let components = newValue.description.split(separator: ".")
        
        if components.count > 1 && components[1].count > 2 {
            quantityString = oldValue
        }
        
        quantity = Float(quantityString) ?? nil
        if (quantity == nil) {
            quantityString = ""
        }
    }
}

#Preview {
    Form {
        QuantityUnitSectionView(
            sectionHeader: "Strength",
            quantityLabel: "Amount",
            unitLabel: "mg, cc...",
            error: "Invalid input",
            quantity: .constant(10),
            unit: .constant("mg")) { _, _ in
                true
            }
    }
}
