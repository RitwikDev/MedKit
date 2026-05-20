//
//  StrengthView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct StrengthView: View {
    @Binding var strength: StrengthModel
    
    var body: some View {
        HStack {
            TextField("Strength Amount", value: $strength.amount, format: .number)
                .keyboardType(.decimalPad)
            Divider()
            TextField("Unit", text: $strength.unit)
        }
    }
}

#Preview {
    StrengthView(strength: .constant(StrengthModel(amount: 100, unit: "mg")))
}
