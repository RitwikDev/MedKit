//
//  ExtensionAddIngredientView.swift
//  MedKit
//
//  Created by Rishik Dev on 17/06/26.
//

import Foundation

extension AddIngredientView {
    func handleOnAppear(
        medicineViewModel: MedicineViewModel,
        allIngredientsModel: [IngredientModel],
        allIngredientsState: inout [Ingredient],
        filteredIngredients: inout [Ingredient],
        medicineComposition: inout [Ingredient]
    ) {
        allIngredientsState = allIngredientsModel.map { .init(from: $0) }
        filteredIngredients = allIngredientsState
        medicineComposition = medicineViewModel.medicine.composition
    }
    
    func addNewIngredient(
        allIngredientsState: inout [Ingredient],
        medicineComposition: inout [Ingredient],
        draftIngredient: inout Ingredient
    ) {
        guard draftIngredient.isValid() else { return }
        
        let trimmedNewIngredientName = draftIngredient.name.trimmed
        let trimmedNewIngredientUnit = draftIngredient.strengthUnit?.trimmed
        let newIngredient = Ingredient(
            name: trimmedNewIngredientName,
            strengthAmount: draftIngredient.strengthAmount,
            strengthUnit: trimmedNewIngredientUnit
        )

        allIngredientsState.append(newIngredient)
        medicineComposition.append(newIngredient)
        
        allIngredientsState.sort { $0.name < $1.name }
        
        draftIngredient = .init()
    }
    
    func addExistingIngredient(
        allIngredientsState: inout [Ingredient],
        medicineComposition: inout [Ingredient],
        ingredient: Ingredient,
        draftIngredient: inout Ingredient
    ) {
        medicineComposition.append(ingredient)
        draftIngredient = .init()
    }
    
    func removeIngredient(
        medicineComposition: inout [Ingredient],
        ingredientToRemove: Ingredient
    ) {
        medicineComposition.removeAll { $0.equalsFullName(ingredientToRemove) }
    }
    
    func filterIn(
        allIngredientsState: inout [Ingredient],
        filteredIngredients: inout [Ingredient],
        draftIngredient: inout Ingredient
    ) {
        if (draftIngredient.name.trimmedIsEmpty) {
            filteredIngredients = allIngredientsState
        } else {
            filteredIngredients = allIngredientsState.filter { $0.name.localizedCaseInsensitiveContains(draftIngredient.name.trimmed) }
        }
    }
    
    func handleSave(
        medicineViewModel: MedicineViewModel,
        medicineComposition: [Ingredient]
    ) {
        medicineViewModel.medicine.composition = medicineComposition
    }
    
    func disableAddButton(
        allIngredientsState: [Ingredient],
        medicineComposition: [Ingredient],
        draftIngredient: Ingredient
    ) -> Bool {
        if (allIngredientsState.contains { $0.equalsFullName(draftIngredient) }) {
            return true
        }
        
        if (medicineComposition.contains { $0.equalsName(draftIngredient) }) {
            return true
        }
        
        return !draftIngredient.isValid()
    }
}
