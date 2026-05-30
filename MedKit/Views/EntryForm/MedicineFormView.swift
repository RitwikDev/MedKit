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
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allCompositions: [CompositionModel]
    @Query private var allTagModels: [TagModel]
    
    @State var medicine: Medicine
    @State private var compositionToEdit: Composition? = nil
    @State private var isManagingTags: Bool = false
    
    private var allCompositionStructs: [Composition] {
        allCompositions.map { Composition(from: $0) }
    }
    
    private var allTagStructs: [Tag] {
        allTagModels.map { Tag(from: $0) }
    }
    
    init(medicine: Medicine) {
        self._medicine = State(initialValue: medicine)
    }
    
    var body: some View {
        Form {
            NameSectionView(name: $medicine.name)
            
            StrengthSectionView(
                strengthAmount: $medicine.strengthAmount,
                strengthUnit: $medicine.strengthUnit,
            )
            
            QuantitySectionView(quantity: $medicine.quantity)
            
            DatesSectionView(
                manufacturedDate: $medicine.manufacturedDate,
                expiryDate: $medicine.expiryDate,
            )

            CompositionSectionView(
                medicineComposition: $medicine.composition,
                compositionToEdit: $compositionToEdit
            )
            
            TagsSectionView(tags: $medicine.tags) { isManagingTags.toggle() }
        }
        .sheet(item: $compositionToEdit) { composition in
            ManageMedicineCompositionSheetView(
                medicineComposition: medicine.composition,
                allCompositions: allCompositionStructs,
                compositionToEdit: composition,
            ) { medicineComposition in
                self.medicine.composition = medicineComposition
            }
        }
        .sheet(isPresented: $isManagingTags) {
            ManageMedicineTagsSheetView(
                medicineTags: medicine.tags,
                allTags: allTagStructs,
            ) { medicineTags in
                self.medicine.tags = medicineTags
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveOrUpdateMedicine(from: medicine, in: modelContext)
                    dismiss()
                }
                .tint(.blue)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicine.name.trimmedIsEmpty ? "New Medicine" : medicine.name)")
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    let container = PreviewContainerHelper.getMedicineContainer()
    
    return NavigationStack {
        MedicineFormView(medicine: .init())
    }
    .modelContainer(container)
    .environment(NavigationRouter())
}
