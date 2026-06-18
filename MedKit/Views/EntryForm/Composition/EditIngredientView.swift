//
//  EditIngredientView.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import SwiftUI

struct EditIngredientView: View {
    let ingredient: Ingredient
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineViewModel.self) private var medicineViewModel
    @State private var draftComposition: Ingredient
    
    init(ingredient: Ingredient) {
        self.ingredient = ingredient
        self._draftComposition = State(initialValue: ingredient)
    }
    
    var body: some View {
        Form {
            IngredientEntryView(
                ingredient: $draftComposition,
                composition: medicineViewModel.medicine.composition,
                isInputDisabled: false
            )
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    medicineViewModel.upsertIngredient(draftComposition)
                    dismiss()
                }
                .disabled(!isValid())
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit \(ingredient.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func isValid() -> Bool {
        let isDuplicate = medicineViewModel.medicine.composition.contains { $0.id != draftComposition.id && $0.equalsName(draftComposition) }

        if (!draftComposition.isValid() || isDuplicate) {
            return false
        }
        return true
    }
}

#Preview {
    NavigationStack {
        EditIngredientView(
            ingredient: Ingredient(
                name: "Composition Name",
                strengthAmount: 500,
                strengthUnit: "mcg"
            )
        )
    }
    .environment(MedicineViewModel())
}
