//
//  CompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionSectionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    var body: some View {
        Section("Composition") {
            ForEach(medicineViewModel.medicine.composition) { ingredient in
                Button(ingredient.fullName) {
                    router.navigate(to: .editIngredient(for: ingredient))
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: medicineViewModel.removeIngredient)
            
            Button("Add Ingredient") {
                router.navigate(to: .addIngredient)
            }
        }
    }
}

#Preview {
    Form {
        CompositionSectionView()
    }
    .environment(MedicineViewModel())
    .environment(NavigationRouter())
}
