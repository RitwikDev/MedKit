//
//  StrengthSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

private enum AlertAction {
    case add, edit
}

struct StrengthSectionView: View {
    @Binding var strengthAmount: Float?
    @Binding var strengthUnit: String?
    
    @State private var showAlert: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var alertAction: AlertAction = .add
    @State private var strengthAmountString: String = ""
    @State private var strengthUnitString: String = ""
    
    var body: some View {
        Section("Strength") {
            if let amount = strengthAmount, let unit = strengthUnit {
                HStack {
                    Button("\(amount.formatted(.number.precision(.fractionLength(2)))) \(unit)") {
                        strengthAmountString = amount.description
                        strengthUnitString = unit
                        alertAction = .edit
                        showAlert = true
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    RoundedTintedButtonView() {
                        showDeleteConfirmation.toggle()
                    }
                }
            } else {
                Button("Add Strength") {
                    alertAction = .add
                    showAlert = true
                }
            }
        }
        .confirmationDialog("Delete Strength?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible
        ) {
            Button("Delete") {
                deleteStrength()
            }
        }
        .alert(alertAction == .add ? "Add Strength" : "Edit Strength",
               isPresented: $showAlert) {
            TextField("Amount", text: $strengthAmountString)
                .keyboardType(.decimalPad)
            
            TextField("Unit", text: $strengthUnitString)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Button("Dismiss") { }
            Button("Done", action: editStrength)
                .disabled(disableDoneButton())
        }
    }
    
    private func editStrength() {
        strengthAmount = Float(strengthAmountString) ?? 0
        strengthUnit = strengthUnitString
    }
    
    private func deleteStrength() {
        strengthAmountString = ""
        strengthUnit = ""
        strengthAmount = nil
        strengthUnit = nil
    }
    
    private func disableDoneButton() -> Bool {
        let trimmedStrengthAmountString = strengthAmountString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedStrengthAmountString.isEmpty { return true }
        
        guard let numericAmount = Double(trimmedStrengthAmountString), numericAmount >= 0 else { return true }
        
        if strengthUnitString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        
        return false
    }
}

#Preview {
    StrengthSectionView(strengthAmount: .constant(10), strengthUnit: .constant("mg"))
}
