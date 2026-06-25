//
//  IngredientEntryView.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import SwiftUI

struct IngredientEntryView: View {
    let ingredient: Ingredient
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @State private var draftIngredient: Ingredient
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        self._draftIngredient = State(initialValue: ingredient)
    }
    
    private var isIngredientAlreadyPresent: Bool {
        for medicineIngredient in medicineEditorViewModel.medicine.composition {
            if (draftIngredient.isDuplicate(of: medicineIngredient)) {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $draftIngredient.name)
            }
            
            StrengthSectionView(
                strengthAmount: $draftIngredient.strengthAmount,
                strengthUnit: $draftIngredient.strengthUnit,
                textColour: draftIngredient.name.trimmedIsEmpty ? .secondary : .primary
            )
            .disabled(draftIngredient.name.trimmedIsEmpty)
            
            if (isIngredientAlreadyPresent) {
                Text("This medicine already contains \(draftIngredient.fullName)")
                    .listRowBackground(Color.clear)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    medicineEditorViewModel.upsertIngredient(draftIngredient)
                    dismiss()
                }
                .disabled(!draftIngredient.isValid() || isIngredientAlreadyPresent)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(ingredient.name.trimmedIsEmpty ? "New Ingredient" : "Edit \(ingredient.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        IngredientEntryView(
            ingredient: Ingredient(
                name: "Composition Name",
                strengthAmount: 500,
                strengthUnit: "mcg"
            )
        )
    }
    .environment(GlobalDataViewModel())
    .environment(MedicineEditorViewModel())
}
