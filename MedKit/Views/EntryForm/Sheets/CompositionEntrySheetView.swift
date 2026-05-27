//
//  CompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI

struct CompositionEntrySheetView: View {
    @Query private var availableCompositions: [CompositionModel]
    
    @Binding var medicineCompositionList: [Composition]
    let compositionToEdit: Composition
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftComposition: Composition = .init()
    @State private var showAlert: Bool = false
    
    private var isNewComposition: Bool {
        compositionToEdit.persistentIdentifier == nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(isNewComposition ? "New Composition" : "Edit Composition") {
                    TextField("Composition Name", text: $draftComposition.name)
                }
                
                StrengthSectionView(strengthAmount: $draftComposition.strengthAmount,
                                    strengthUnit: $draftComposition.strengthUnit
                )
                
                Section("Other Compositions") {
                    if !availableCompositions.isEmpty {
                        ForEach(availableCompositions) { availableComposition in
                            Button(availableComposition.getFullName()) {
                                // Explicitly preserve the existing ID/passport while applying sample data templates
                                draftComposition.name = availableComposition.name
                                draftComposition.strengthAmount = availableComposition.strengthAmount
                                draftComposition.strengthUnit = availableComposition.strengthUnit
                            }
                            .foregroundStyle(.primary)
                        }
                    } else {
                        EmptyEntryView(text: "No other compositions added")
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
                        
                        let isSuccessful = onSave(composition: finalComposition)
                        if isSuccessful {
                            dismiss()
                        }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .disabled(draftComposition.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("Dismiss") { }
            } message: {
                Text("Same composition already exists for this medicine")
            }
            .interactiveDismissDisabled()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Composition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func onSave(composition: Composition) -> Bool {
        // Duplicate composition
        if medicineCompositionList.first(where: { composition.isDuplicate(of: $0) }) != nil {
            showAlert = true
            return false
        }
        
        if let index = medicineCompositionList.firstIndex(where: { composition.id == $0.id }) {
            medicineCompositionList[index].name = composition.name
            medicineCompositionList[index].strengthAmount = composition.strengthAmount
            medicineCompositionList[index].strengthUnit = composition.strengthUnit
        } else {
            medicineCompositionList.append(composition)
        }
        
        return true
    }
}

#Preview {
    NavigationStack {
        CompositionEntrySheetView(
            medicineCompositionList: .constant([]),
            compositionToEdit: .init(),
        )
    }
}
