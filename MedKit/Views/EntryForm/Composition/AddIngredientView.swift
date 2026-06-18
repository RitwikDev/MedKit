//
//  AddIngredientView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftData
import SwiftUI

struct AddIngredientView: View {
    @Query(sort: \IngredientModel.name) private var allIngredientsModel: [IngredientModel]
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    @State private var draftIngredient: Ingredient = .init()
    @State private var allIngredientsState: [Ingredient] = []
    @State private var filteredIngredients: [Ingredient] = []
    // TODO: - Store medicineComposition in a Set
    @State private var medicineComposition: [Ingredient] = []
    @State private var showUnsavedChangesConfirmationDialog: Bool = false
    
    var body: some View {
        Form {
            IngredientEntryView(
                ingredient: $draftIngredient,
                composition: medicineViewModel.medicine.composition,
                isInputDisabled: false
            )
            addButtonsSectionView
            allIngredientsSectionView
        }
        .onAppear {
            handleOnAppear(
                medicineViewModel: medicineViewModel,
                allIngredientsModel: allIngredientsModel,
                allIngredientsState: &allIngredientsState,
                filteredIngredients: &filteredIngredients,
                medicineComposition: &medicineComposition
            )
        }
        .onChange(of: draftIngredient) { _, _ in
            filterIn(
                allIngredientsState: &allIngredientsState,
                filteredIngredients: &filteredIngredients,
                draftIngredient: &draftIngredient
            )
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                confirmationToolbarItem
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Add Ingredient")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var addButtonsSectionView: some View {
        Button("Add \(draftIngredient.fullName)") {
            addNewIngredient(
                allIngredientsState: &allIngredientsState,
                medicineComposition: &medicineComposition,
                draftIngredient: &draftIngredient
            )
        }
        .disabled(
            disableAddButton(
                allIngredientsState: allIngredientsState,
                medicineComposition: medicineComposition,
                draftIngredient: draftIngredient
            )
        )
    }
    
    private var allIngredientsSectionView: some View {
        Section("All Ingredients") {
            if (filteredIngredients.isEmpty) {
                EmptyEntryView(text: allIngredientsState.isEmpty ? "No Ingredients Added" : "No Results Found")
            } else {
                ForEach(filteredIngredients) { ingredient in
                    // medicineComposition contains 'ingredient'.
                    if (medicineComposition.first { $0.equalsPersistentId(ingredient) } != nil) {
                        ingredientExistsInMedicineView(ingredient)
                    } else {
                        // medicineComposition does not contain 'ingredient' but there may be multiple
                        // ingredients with the same fullName (they may be associated with other medicines).
                        // Such ingredients should not be shown. This might be avoided if medicineComposition
                        // is stored in a Set rather than in an Array.
                        if (medicineComposition.first { $0.equalsFullName(ingredient) } == nil) {
                            ingredientDoesNotExistInMedicineView(ingredient)
                        }
                    }
                }
            }
        }
    }
    
    private func ingredientExistsInMedicineView(_ ingredient: Ingredient) -> some View {
        HStack {
            Text(ingredient.fullName)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.blue)
        }
        .swipeActions {
            Button("Remove") {
                withAnimation {
                    removeIngredient(medicineComposition: &medicineComposition, ingredientToRemove: ingredient)
                }
            }
            .tint(.red)
        }
    }
    
    private func ingredientDoesNotExistInMedicineView(_ ingredient: Ingredient) -> some View {
        Text(ingredient.fullName)
            .swipeActions(edge: .leading) {
                Button("Add") {
                    withAnimation {
                        addExistingIngredient(
                            allIngredientsState: &allIngredientsState,
                            medicineComposition: &medicineComposition,
                            ingredient: ingredient,
                            draftIngredient: &draftIngredient
                        )
                    }
                }
                .tint(.blue)
                
                Button("Edit") {
                    withAnimation {
                        draftIngredient = ingredient
                    }
                }
                .tint(.indigo)
            }
    }
    
    private var confirmationToolbarItem: some View {
        Button("Done") {
            if (draftIngredient.name.trimmedIsEmpty) {
                handleSave(medicineViewModel: medicineViewModel, medicineComposition: medicineComposition)
                dismiss()
            } else {
                showUnsavedChangesConfirmationDialog.toggle()
            }
        }
        .confirmationDialog(
            "You have some unsaved changes",
            isPresented: $showUnsavedChangesConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                handleSave(medicineViewModel: medicineViewModel, medicineComposition: medicineComposition)
                dismiss()
            }
        } message: {
            Text("Are you sure you do not want to save \(draftIngredient.fullName)?")
        }
    }
}

#Preview {
    NavigationStack {
        AddIngredientView()
            .environment(MedicineViewModel())
            .modelContainer(PreviewData.container)
    }
}
