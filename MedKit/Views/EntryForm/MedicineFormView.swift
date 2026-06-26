//
//  MedicineFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftUI

struct MedicineFormView: View {
    let medicine: Medicine

    @Environment(NavigationRouter.self) private var router
    @State private var medicineEditorViewModel: MedicineEditorViewModel
        
    init(medicine: Medicine) {
        self.medicine = medicine
        self._medicineEditorViewModel = State(initialValue: .init(medicine: medicine))
    }
    
    var body: some View {
        Form {
            NameSectionView(name: $medicineEditorViewModel.medicine.name)
            
            StrengthSectionView(
                strengthAmount: $medicineEditorViewModel.medicine.strengthAmount,
                strengthUnit: $medicineEditorViewModel.medicine.strengthUnit,
            )
            
            QuantitySectionView(quantity: $medicineEditorViewModel.medicine.quantity)
            
            DatesSectionView(
                manufacturedDate: $medicineEditorViewModel.medicine.manufacturedDate,
                expiryDate: $medicineEditorViewModel.medicine.expiryDate,
            )

            CompositionSectionView()
            
            ScheduleSectionView(schedule: $medicineEditorViewModel.medicine.schedule)

            TagsSectionView()
            
            CustomFieldsSectionView()
        }
        .environment(medicineEditorViewModel)
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
        .navigationTitle("\(medicine.name.trimmedIsEmpty ? "New Medicine" :  medicine.name)")
    }
}

#Preview {
    NavigationStack {
        MedicineFormView(medicine: .init())
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
