//
//  StrengthSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct StrengthSectionView: View {
    @Binding var quantity: Float?
    @Binding var unit: String?
    
    var body: some View {
        QuantityUnitSectionView(
            sectionHeader: "Strength (Optional)",
            quantityLabel: "Amount",
            unitLabel: "mg/ml...",
            error: "Strength is not valid",
            quantity: $quantity,
            unit: $unit,
            isValid: isValid,
        )
    }
    
    private func isValid(quantity: Float?, unit: String?) -> Bool {
        let bothNil = quantity == nil && unit == nil
        let bothNotNil = (quantity != nil && quantity ?? 0 > 0) && unit != nil
        
        return bothNil || bothNotNil
    }
}

#Preview {
    Form {
        StrengthSectionView(quantity: .constant(10), unit: .constant("mg"))
    }
}
