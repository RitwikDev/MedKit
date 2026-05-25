//
//  CompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionEntrySheetView: View {
    private let sampleList: [CompositionModel] = sampleCompositions

    let medicineCompositionList: [Composition]
    let compositionToEdit: Composition
    
    var onSave: (Composition) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftComposition: Composition = .init()
    
    private var isNewComposition: Bool {
        compositionToEdit.persistentIdentifier == nil
    }
 
    var body: some View {
        NavigationStack {
            List {
                Section(isNewComposition ? "New Composition" : "Edit Composition") {
                    TextField("Composition Name", text: $draftComposition.name)
                }
                
                StrengthSectionView(strengthAmount: $draftComposition.strengthAmount, strengthUnit: $draftComposition.strengthUnit)
                
                if !sampleList.isEmpty {
                    Section("Previously Added Compositions") {
                        ForEach(sampleList) { sampleItem in
                            Button(sampleItem.getFullName()) {
                                // Explicitly preserve the existing ID/passport while applying sample data templates
                                draftComposition.name = sampleItem.name
                                draftComposition.strengthAmount = sampleItem.strengthAmount
                                draftComposition.strengthUnit = sampleItem.strengthUnit
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .onAppear {
                draftComposition = compositionToEdit
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Label("Dismiss", systemImage: "xmark") }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        var finalComposition = draftComposition
                        finalComposition.name = finalComposition.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        onSave(finalComposition)
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
}

#Preview {
    NavigationStack {
        CompositionEntrySheetView(
            medicineCompositionList: [],
            compositionToEdit: .init(),
            onSave: { _ in }
        )
    }
}
