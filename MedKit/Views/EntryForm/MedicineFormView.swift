//
//  MedicineFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftUI

struct MedicineFormView: View {
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        @Bindable var bindableViewModel = medicineEditorViewModel
        
        Form {
            NameSectionView(name: $bindableViewModel.medicine.name)
            
            StrengthSectionView(
                strengthAmount: $bindableViewModel.medicine.strengthAmount,
                strengthUnit: $bindableViewModel.medicine.strengthUnit,
            )
            
            QuantitySectionView(quantity: $bindableViewModel.medicine.quantity)
            
            DatesSectionView(
                manufacturedDate: $bindableViewModel.medicine.manufacturedDate,
                expiryDate: $bindableViewModel.medicine.expiryDate,
            )

            CompositionSectionView()
            
            ScheduleSectionView(schedule: $bindableViewModel.medicine.schedule)

            TagsSectionView()
            
            CustomFieldsSectionView()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        try medicineEditorViewModel.saveMedicine()
                        router.popToRoot()
                    } catch {
                        
                    }
                }
                .tint(.blue)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicineEditorViewModel.medicine.name.trimmedIsEmpty ? "New Medicine" :  medicineEditorViewModel.medicine.name)")
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    
    return NavigationStack {
        MedicineFormView()
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
