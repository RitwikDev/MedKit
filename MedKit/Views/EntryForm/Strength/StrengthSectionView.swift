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
    var textColour: Color = .primary
    
    @State var strengthAmountString: String = ""
    @State var strengthUnitString: String = ""
    
    var body: some View {
        Section(content: {
            VStack {
                TextField("Amount", text: $strengthAmountString)
                    .keyboardType(.decimalPad)
                    .onChange(of: strengthAmountString) { oldValue, newValue in
                        handleOnChange(oldValue: oldValue, newValue: newValue)
                    }
                
                Divider()
                
                TextField("Unit", text: $strengthUnitString)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: strengthUnitString) { oldValue, newValue in
                        strengthUnit = newValue.trimmedIsEmpty ? nil : newValue
                    }
            }
            .foregroundStyle(textColour)
            .onAppear(perform: handleStrengthChange)
            .onChange(of: [strengthAmount, strengthUnit] as [AnyHashable]) {
                handleStrengthChange()
            }
        }, header: {
            Text("Strength (Optional)")
        }, footer: {
            if ((strengthAmount != nil && strengthUnit == nil)
                || (strengthAmount == nil && strengthUnit != nil))
                || ((strengthAmount ?? 1) <= 0) {
                Text("Strength is not valid")
                    .foregroundStyle(.red)
            }
        })
    }
}

#Preview {
    Form {
        StrengthSectionView(strengthAmount: .constant(10), strengthUnit: .constant("mg"))
    }
}
