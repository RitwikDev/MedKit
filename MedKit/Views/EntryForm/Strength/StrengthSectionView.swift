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
        )
    }
}

#Preview {
    Form {
        StrengthSectionView(quantity: .constant(10), unit: .constant("mg"))
    }
}
