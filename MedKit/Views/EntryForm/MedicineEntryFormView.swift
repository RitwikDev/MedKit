//
//  MedicineEntryFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftData
import SwiftUI

struct MedicineEntryFormView: View {
    @Environment(\.modelContext) private var mainModelContext // Rename for clarity
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var medicine: MedicineModel
    @State private var compositionToEdit: CompositionModel? = nil
    
    private let editingContext: ModelContext
    private let isNew: Bool
    
    init(container: ModelContainer, medicine: MedicineModel? = nil) {
        let context = ModelContext(container)
        context.autosaveEnabled = false
        self.editingContext = context
        
        if let medicine, medicine.persistentModelID.storeIdentifier != nil {
            let editableMedicine = context.model(for: medicine.persistentModelID) as! MedicineModel
            self._medicine = Bindable(editableMedicine)
            self.isNew = false
        } else {
            let newMedicine = MedicineModel()
            context.insert(newMedicine)
            self._medicine = Bindable(newMedicine)
            self.isNew = true
        }
    }
    
    var body: some View {
        Form {
            NameSectionView(name: $medicine.name)
            
            StrengthSectionView(strength: $medicine.strength)
            
            QuantitySectionView(quantity: $medicine.quantity)
            
            DatesSectionView(manufacturedDate: $medicine.manufacturedDate, expiryDate: $medicine.expiryDate)

            CompositionSectionView(
                compositionList: $medicine.composition,
                compositionToEdit: $compositionToEdit
            )
        
            CustomFieldsSectionView(customFields: $medicine.customFields) {}
            
            TagsSectionView(tags: $medicine.tags)
            
            Button("Save") {
                do {
                    try editingContext.save()
                    
                    if isNew {
                        mainModelContext.insert(medicine)
                    }
                    
                    try mainModelContext.save()
                } catch {
                    print("Failed to save: \(error)")
                }
                dismiss()
            }
            
            Button("Cancel", role: .destructive) {
                dismiss()
            }
        }
        .sheet(item: $compositionToEdit) { composition in
            CompositionEntrySheetView(
                medicine: medicine,
                compositionToEdit: composition,
                modelContext: editingContext
            )
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicine.name.isEmpty ? "New Medicine" : medicine.name)")
    }
}

#Preview {
    do {
        let container = try PreviewContainerHelper.getMedicineContainer()
        let medicine: MedicineModel = sampleMedicines[7]
        
        container.mainContext.insert(medicine)
        
        return NavigationStack {
            MedicineEntryFormView(
                container: container,
                medicine: medicine
            )
        }
    } catch {
        fatalError("Error")
    }
}
