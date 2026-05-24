//
//  MedicineEntryFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftUI

struct MedicineEntryFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
//    @State var medicine: MedicineModel
    @Bindable var draftMedicine: MedicineModel
    @State private var compositionToEdit: CompositionModel? = nil
    
//    init(medicine: MedicineModel) {
//        self._medicine = State(initialValue: medicine)
//        self._draftMedicine = State(initialValue: medicine.copy())
//    }
    
    var body: some View {
        Form {
            NameSectionView(name: $draftMedicine.name)
            
            StrengthSectionView(strength: $draftMedicine.strength)
            
            QuantitySectionView(medicine: draftMedicine)
            
//            DatesSectionView(medicine: $draftMedicine)
//
//            CompositionSectionView(
//                compositionList: $draftMedicine.composition,
//                compositionToEdit: $compositionToEdit,
//            )
//        
//            CustomFieldsSectionView(customFields: $draftMedicine.customFields) {
//            }
//
//            TagsSectionView(tags: $draftMedicine.tags)
            
//            Button("Save") {
//                medicine = draftMedicine
////                if modelContext.hasChanges {
//                    do {
//                        try modelContext.save()
//                    } catch (let error) {
//                        print(error)
//                    }
////                }
//                dismiss()
//            }
            
            Button("Cancel", role: .destructive) {
                dismiss()
            }
        }
        .sheet(item: $compositionToEdit, content: { composition in
            CompositionEntrySheetView(composition: $draftMedicine.composition, compositionToEdit: composition)
        })
        .scrollDismissesKeyboard(.interactively)
//        .navigationTitle("\(medicine.name.isEmpty ? "New Medicine" : medicine.name)")
    }
}

//#Preview {
//    NavigationStack {
//        MedicineEntryFormView(
//            medicine: sampleMedicines[7]
//        )
//    }
//}
