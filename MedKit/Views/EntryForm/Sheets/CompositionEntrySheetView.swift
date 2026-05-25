//
//  CompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI

struct CompositionEntrySheetView: View {
    private let compositionList = sampleCompositions
    
    let medicine: MedicineModel
    let compositionToEdit: CompositionModel
    let modelContext: ModelContext
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftComposition: CompositionModel = .init()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // If the object isn't committed to a context store yet, it's in Add Mode
    private var isNewComposition: Bool {
        compositionToEdit.persistentModelID.storeIdentifier == nil
    }
 
    var body: some View {
        NavigationStack {
            List {
                Section(isNewComposition ? "New Composition" : "Edit Composition") {
                    TextField("Composition Name", text: $draftComposition.name)
                }
                
                StrengthSectionView(strength: $draftComposition.strength)
                
                Section("Previously Added Compositions") {
                    ForEach(compositionList, id: \.self) { compositionItem in
                        Button(compositionItem.getFullName()) {
                            draftComposition = compositionItem.copy()
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .onAppear {
                draftComposition = compositionToEdit.copy()
            }
            .alert("Something went wrong", isPresented: $showError) {
                Button("Dismiss") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Label("Dismiss", systemImage: "xmark") }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveChanges()
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .disabled(draftComposition.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .interactiveDismissDisabled()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Composition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveChanges() {
        let cleanedName = draftComposition.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isNewComposition {
            // 1. Configure the brand new target instance inside the context
            compositionToEdit.name = cleanedName
            modelContext.insert(compositionToEdit)
            
            if let targetStrength = draftComposition.strength {
                let newStrength = StrengthModel(amount: targetStrength.amount, unit: targetStrength.unit)
                modelContext.insert(newStrength)
                compositionToEdit.strength = newStrength
            }
            
            // 2. Append directly to the parent relationship array
            medicine.composition.append(compositionToEdit)
            
        } else {
            // EDIT MODE: Update existing values in-place on the tracking instance
            compositionToEdit.name = cleanedName
            
            if let draftStrength = draftComposition.strength {
                if let existingStrength = compositionToEdit.strength {
                    existingStrength.amount = draftStrength.amount
                    existingStrength.unit = draftStrength.unit
                } else {
                    let newStrength = StrengthModel(amount: draftStrength.amount, unit: draftStrength.unit)
                    modelContext.insert(newStrength)
                    compositionToEdit.strength = newStrength
                }
            } else {
                compositionToEdit.strength = nil
            }
        }
    }
}

#Preview {
    do {
        let container = try PreviewContainerHelper.getMedicineContainer()
        
        return NavigationStack {
            CompositionEntrySheetView(
                medicine: sampleMedicines[7],
                compositionToEdit: .init(),
                modelContext: container.mainContext
            )
        }
    } catch {
        fatalError("Error building preview for CompositionEntrySheetView")
    }
}
