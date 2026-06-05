//
//  MedicineFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftData
import SwiftUI

struct MedicineFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MedicineViewModel.self) private var medicineViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var bindableViewModel = medicineViewModel
        
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
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveOrUpdateMedicine(from: medicineViewModel.medicine, in: modelContext)
                    dismiss()
                }
                .tint(.blue)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicineViewModel.medicine.name.trimmedIsEmpty ? "New Medicine" :  medicineViewModel.medicine.name)")
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    let container = PreviewContainerHelper.getMedicineContainer()
    
    return NavigationStack {
        MedicineFormView()
    }
    .modelContainer(container)
    .environment(MedicineViewModel())
    .environment(NavigationRouter())
}
