//
//  StrengthView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

private enum AlertAction {
    case add, edit
}

struct StrengthView: View {
    @Binding var strength: StrengthModel?
    
    @State private var showAlert: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var alertAction: AlertAction = .add
    @State private var strengthAmountString: String = ""
    @State private var strengthUnit: String = ""
    
    var body: some View {
        Group {
            if let strength = strength {
                HStack {
                    Button("\(strength.amount.formatted(.number.precision(.fractionLength(2)))) \(strength.unit)") {
                        strengthAmountString = strength.amount.description
                        strengthUnit = strength.unit
                        alertAction = .edit
                        showAlert = true
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    RoundedTintedButtonView(buttonAction: { showDeleteConfirmation.toggle() },
                                            title: "Delete",
                                            systemImage: "xmark",
                                            tintColor: .red)
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
            Button("Cancel") { }
        }
        .alert(alertAction == .add ? "Add Strength" : "Edit Strength",
               isPresented: $showAlert) {
            TextField("Amount", text: $strengthAmountString)
                .keyboardType(.decimalPad)
            
            TextField("Unit", text: $strengthUnit)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Button("Dismiss") { }
            Button("Done", action: editStrength)
                .disabled(disableDoneButton())
        }
    }
    
    private func editStrength() {
        strength = .init(amount: Float(strengthAmountString) ?? 0, unit: strengthUnit)
    }
    
    private func deleteStrength() {
        strengthAmountString = ""
        strengthUnit = ""
        strength = nil
    }
    
    private func disableDoneButton() -> Bool {
        let trimmedStrengthAmountString = strengthAmountString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedStrengthAmountString.isEmpty { return true }
        
        guard let numericAmount = Double(trimmedStrengthAmountString), numericAmount >= 0 else { return true }
        
        if strengthUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        
        return false
    }
}

#Preview {
    StrengthView(strength: .constant(.init(amount: 20, unit: "mg")))
}
