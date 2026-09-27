//
//  StrengthSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct StrengthSectionView: View {
    @Environment(GlobalDataViewModel.self) private var globalViewModel
    
    @Binding var amount: Float?
    @Binding var unit: String?
    @State var amountString: String = ""
    @State var unitString: String = ""
    @State var showUnitSuggestions: Bool = false
    @FocusState var isUnitFocused: Bool
    
    private var isValid: Bool {
        let bothEmpty = amountString.trimmedIsEmpty && unitString.trimmedIsEmpty
        let bothNotEmpty = !amountString.trimmedIsEmpty && !unitString.trimmedIsEmpty
        
        return bothEmpty || bothNotEmpty
    }
    
    private var isAmountZero: Bool {
        (amount ?? 0).isZero
    }
    
    private var unitOptions: Set<String> {
        globalViewModel
            .allStrengthUnits
            .filter({ unitString.trimmedIsEmpty || $0.localizedStandardContains(unitString) })
    }
    
    var body: some View {
        Section(content: {
            VStack {
                TextField("Amount", text: $amountString)
                    .keyboardType(.decimalPad)
                    .onChange(of: amountString) { old, new in
                        handleAmountChanged(old, new)
                    }
                
                Divider()
                
                unitView
            }
            .onAppear {
                if let amount = amount {
                    // Check if it has decimal places that are 0 to keep it looking integer-like
                    if amount.truncatingRemainder(dividingBy: 1) == 0 {
                        amountString = String(Int(amount))
                    } else {
                        amountString = String(amount)
                    }
                }
                if let unit = unit {
                    unitString = unit
                }
            }
        }, header: {
            Text("Strength")
        }, footer: {
            if (!isValid) {
                Text("Invalid input.")
                    .foregroundStyle(.red)
            }
        })
    }
    
    private var unitView: some View {
        TextField("mg / ml...", text: $unitString)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($isUnitFocused)
            .onChange(of: unitString) { _old, new in
                handleUnitChanged(new)
            }
            .onChange(of: isUnitFocused) { oldValue, newValue in
                withAnimation {
                    showUnitSuggestions = newValue
                }
            }
            .toolbar {
                if (showUnitSuggestions) {
                    ToolbarItemGroup(placement: .keyboard) {
                        SelectableChipsView(options: unitOptions) { selectedUnit in
                            isUnitFocused = false
                            unitString = selectedUnit
                        }
                    }
                }
            }
    }
    
    private func handleAmountChanged(_ old: String, _ new: String) -> Void {
        if new.trimmedIsEmpty {
            amountString = ""
            updateStrength(newAmount: nil, newUnit: unitString)
            return
        }
        
        guard let amount = Float(new.trimmed) else {
            amountString = old
            return
        }

        if (amount >= 0) {
            updateStrength(newAmount: amount, newUnit: unitString)
        } else {
            amountString = old
        }
    }
    
    private func handleUnitChanged(_ unit: String) -> Void {
        updateStrength(newAmount: Float(amountString), newUnit: unit.trimmed)
    }
    
    private func updateStrength(newAmount: Float?, newUnit: String?) {
        // We always push the current state up to the bindings so the view model sees exactly what the user typed.
        if amountString.trimmedIsEmpty {
            self.amount = nil
        } else {
            self.amount = newAmount
        }
        
        if unitString.trimmedIsEmpty {
            self.unit = nil // or "" depending on preference, but nil matches initial state
        } else {
            self.unit = newUnit ?? ""
        }
    }
}

#Preview {
    Form {
        StrengthSectionView(
            amount: .constant(1),
            unit: .constant("mg")
        )
            .environment(MedicineEditorViewModel())
            .environment(GlobalDataViewModel())
    }
}
