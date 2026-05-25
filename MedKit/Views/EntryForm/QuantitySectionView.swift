//
//  QuantitySectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct QuantitySectionView: View {
    @Binding var quantity: Float
    
    var body: some View {
        Section("Quantity") {
            Stepper(quantity.description, value: $quantity, in: 0...100)
        }
    }
}

#Preview {
    QuantitySectionView(quantity: .constant(12.5))
}
