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
    
    @State var strengthAmountString: String = ""
    @State var strengthUnitString: String = ""
    
    var body: some View {
        Section("Strength (Optional)") {
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
                        strengthUnit = newValue
                    }
            }
            .onAppear(perform: handleStrengthChange)
            .onChange(of: [strengthAmount, strengthUnit] as [AnyHashable]) {
                handleStrengthChange()
            }
        }
    }
}

#Preview {
    Form {
        StrengthSectionView(strengthAmount: .constant(10), strengthUnit: .constant("mg"))
    }
}
