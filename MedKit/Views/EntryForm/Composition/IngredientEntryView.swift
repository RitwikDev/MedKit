//
//  IngredientEntryView.swift
//  MedKit
//
//  Created by Rishik Dev on 31/05/26.
//

import SwiftUI

struct IngredientEntryView: View {
    @Binding var ingredient: Ingredient
    let composition: [Ingredient]
    let isInputDisabled: Bool
    
    var body: some View {
        Group {
            Section(content: {
                TextField("Name", text: $ingredient.name)
            }, header: {
                Text("Name")
            }, footer: {
                if (isDuplicate) {
                    Text("Ingredient already exists")
                        .foregroundStyle(.red)
                }
            })
            .disabled(isInputDisabled)
            
            StrengthSectionView(
                strengthAmount: $ingredient.strengthAmount,
                strengthUnit: $ingredient.strengthUnit
            )
            .disabled(isInputDisabled)
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var isDuplicate: Bool {
        composition.contains(where: { $0.id != ingredient.id && $0.equalsName(ingredient) })
    }
}

#Preview {
    Form {
        IngredientEntryView(
            ingredient: .constant(Ingredient(
                name: "Ingredient Name",
                strengthAmount: 500,
                strengthUnit: "mcg"
            )),
            composition: [],
            isInputDisabled: false
        )
    }
    .environment(MedicineViewModel())
}
