//
//  StockSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct StepperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .background(configuration.isPressed ? Color(UIColor.secondarySystemFill) : Color.clear)
    }
}

struct StockSectionView: View {
    @Environment(MedicineEditorViewModel.self) private var medicineViewModel
    @Environment(GlobalDataViewModel.self) private var globalViewModel
    
    @State var quantityString: String = ""
    @State var unitString: String = ""
    @State var showUnitSuggestions: Bool = false
    @FocusState var isUnitFocused: Bool
    
    private var isValid: Bool {
        let bothEmpty = quantityString.trimmedIsEmpty && unitString.trimmedIsEmpty
        let bothNotEmpty = !quantityString.trimmedIsEmpty && !unitString.trimmedIsEmpty
        
        return bothEmpty || bothNotEmpty
    }
    
    private var isQuantityZero: Bool {
        (medicineViewModel.medicine.stock?.quantity ?? 0).isZero
    }
    
    private var unitOptions: Set<String> {
        globalViewModel
            .allStockTypes
            .filter({ unitString.trimmedIsEmpty || $0.localizedStandardContains(unitString) })
    }
    
    var body: some View {
        Section(content: {
            VStack {
                quantityView
                
                Divider()
                
                unitView
            }
            .onAppear {
                if let quantity = medicineViewModel.medicine.stock?.quantity {
                    quantityString = String(quantity)
                }
                if let unit = medicineViewModel.medicine.stock?.unit {
                    unitString = unit
                }
            }
        }, header: {
            Text("Stock")
        }, footer: {
            if (!isValid) {
                Text("Invalid input")
                    .foregroundStyle(.red)
            }
        })
    }
    
    private var quantityView: some View {
        HStack {
            TextField("Quantity", text: $quantityString)
                .keyboardType(.decimalPad)
                .onChange(of: quantityString) { old, new in
                    handleQuantityChanged(old, new)
                }
            
            HStack(spacing: 0) {
                Button {
                    updateQuantity(isIncrement: false)
                } label: {
                    Image(systemName: "minus")
                        .foregroundColor(isValid && !isQuantityZero ? .primary : .gray.opacity(0.5))
                }
                .disabled(isQuantityZero)
                
                Divider()
                    .padding(.vertical, 5)
                
                Button {
                    updateQuantity(isIncrement: true)
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(isValid ? .primary : .gray.opacity(0.5))
                }
            }
            .frame(width: 95, height: 30)
            .background(Color(UIColor.tertiarySystemFill))
            .buttonStyle(StepperButtonStyle())
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .disabled(!isValid)
        }
    }
    
    private var unitView: some View {
        TextField("Tablet/Drop...", text: $unitString)
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
    
    private func updateQuantity(isIncrement: Bool) -> Void {
        if let quantity = Float(quantityString) {
            var step = medicineViewModel.medicine.dosage?.dosageQuantity ?? 1
            step = isIncrement ? step : -1 * step
            let newQuantity = max(0, quantity + step)
            quantityString = String(newQuantity)
        }
    }
    
    private func handleQuantityChanged(_ old: String, _ new: String) -> Void {
        guard let quantity = Float(new.trimmed) else {
            quantityString = new.trimmed == "" ? "" : old
            return
        }

        if (quantity >= 0) {
            updateStock(newQuantity: quantity, newUnit: unitString)
        } else {
            quantityString = old
        }
    }
    
    private func handleUnitChanged(_ unit: String) -> Void {
        updateStock(newQuantity: Float(quantityString), newUnit: unit.trimmed)
    }
    
    private func updateStock(newQuantity: Float?, newUnit: String?) {
        if (!isValid) {
            return
        }
        
        if let quantity = newQuantity, let unit = newUnit {
            medicineViewModel.medicine.stock = StockModel(quantity: quantity, unit: unit)
        } else {
            medicineViewModel.medicine.stock = nil
        }
    }
}

#Preview {
    Form {
        StockSectionView()
            .environment(MedicineEditorViewModel())
            .environment(GlobalDataViewModel())
    }
}
