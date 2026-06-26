//
//  IngredientEntryView.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import SwiftUI

struct IngredientEntryView: View {
    let ingredient: Ingredient
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftIngredient: Ingredient
    
    init(ingredient: Ingredient, medicineEditorViewModel: MedicineEditorViewModel) {
        self.ingredient = ingredient
        self.medicineEditorViewModel = medicineEditorViewModel
        self._draftIngredient = State(initialValue: ingredient)
    }
    
    private var ingredientExists: Bool {
        medicineEditorViewModel.medicine.composition.contains {
            $0.fullName.trimmedLocalizedCaseInsensitiveEquals(draftIngredient.fullName)
        }
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
            
            if (ingredientExists) {
                Text("This medicine already contains \(draftIngredient.fullName)")
                    .listRowBackground(Color.clear)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation {
                            medicineEditorViewModel.upsertIngredient(draftIngredient)
                        }
                    }
                    
                    dismiss()
                }
                .disabled(!draftIngredient.isValid() || ingredientExists)
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
            ),
            medicineEditorViewModel: .init()
        )
    }
}
