//
//  MedicineEntryFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftData
import SwiftUI

struct MedicineEntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query var allTagModels: [TagModel]
    
    @State var medicine: Medicine
    @State private var compositionToEdit: Composition? = nil
    @State private var isManagingTags: Bool = false
    
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
                compositionList: $medicine.composition,
                compositionToEdit: $compositionToEdit
            )
            
            TagsSectionView(tags: $medicine.tags) { isManagingTags.toggle() }
        }
        .sheet(item: $compositionToEdit) { composition in
            CompositionEntrySheetView(
                medicineCompositionList: $medicine.composition,
                compositionToEdit: composition,
            )
        }
        .sheet(isPresented: $isManagingTags) {
            ManageMedicineTagsView(
                medicineTags: $medicine.tags,
                allTags: allTagStructs
            )
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
        .navigationTitle("\(medicine.name.isEmpty ? "New Medicine" : medicine.name)")
    }
}

#Preview {
    let container = PreviewContainerHelper.getMedicineContainer()
    
    return NavigationStack {
        MedicineEntryFormView(medicine: .init())
    }
    .modelContainer(container)
}
