//
//  StockSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct StockSectionView: View {
    @Binding var quantity: Float?
    @Binding var unit: String?
    
    var body: some View {
        QuantityUnitSectionView(
            sectionHeader: "Stock",
            quantityLabel: "Quantity",
            unitLabel: "Tablet/Drop...",
            error: "Invalid input",
            quantity: $quantity,
            unit: $unit,
        )
    }
}

#Preview {
    StockSectionView(
        quantity: .constant(12.5),
        unit: .constant("Tablet"),
    )
}
