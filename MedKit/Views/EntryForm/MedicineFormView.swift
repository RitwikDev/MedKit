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
    @Environment(NavigationRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var medicineRepository: MedicineWriteRepository?
    
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
            
            CustomFieldsSectionView()
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    router.popToRoot()
                    _ = try? self.medicineRepository?.save(medicine: medicineViewModel.medicine)
                    dismiss()
                }
                .tint(.blue)
            }
        }
        .onAppear {
            if self.medicineRepository == nil {
                self.medicineRepository = MedicineWriteRepository(modelContext: self.modelContext)
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
    .environment(PreviewData.medicineViewModels[0])
    .environment(NavigationRouter())
}
