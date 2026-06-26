//
//  CompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionSectionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    
    var body: some View {
        Section("Composition") {
            ForEach(medicineEditorViewModel.medicine.composition) { ingredient in
                Button(ingredient.fullName) {
                    router.navigate(to: .ingredientForm(for: ingredient, medicineEditorViewModel: medicineEditorViewModel))
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: medicineEditorViewModel.removeIngredient)
            
            Button("Add Ingredient") {
                router.navigate(to: .ingredientForm(for: .init(), medicineEditorViewModel: medicineEditorViewModel))
            }
        }
    }
}

#Preview {
    Form {
        CompositionSectionView()
    }
    .environment(GlobalDataViewModel())
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
