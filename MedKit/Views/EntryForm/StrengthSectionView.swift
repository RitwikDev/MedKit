//
//  StrengthSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct StrengthSectionView: View {
    @Binding var strengthAmount: Float?
    @Binding var strengthUnit: String?
    
    @State private var strengthAmountString: String = ""
    @State private var strengthUnitString: String = ""
    
    var body: some View {
        Section("Strength (Optional)") {
            VStack {
                TextField("Amount", text: $strengthAmountString)
                    .keyboardType(.decimalPad)
                    .onChange(of: strengthAmountString) { oldValue, newValue in
                        let components = newValue.description.split(separator: ".")
                        
                        if components.count > 1 && components[1].count > 2 {
                            strengthAmountString = oldValue
                        }
                        
                        strengthAmount = Float(strengthAmountString) ?? nil
                    }
                
                Divider()
                
                TextField("Unit", text: $strengthUnitString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: strengthUnitString) { oldValue, newValue in
                        strengthUnit = newValue
                    }
            }
            .onAppear {
                if let amount = strengthAmount {
                    strengthAmountString = String(format: "%g", amount)
                } else {
                    strengthAmountString = ""
                }
                
                strengthUnitString = strengthUnit ?? ""
            }
        }
    }
}

#Preview {
    StrengthSectionView(strengthAmount: .constant(10), strengthUnit: .constant("mg"))
}
