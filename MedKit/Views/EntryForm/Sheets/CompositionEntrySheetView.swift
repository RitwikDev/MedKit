//
//  CompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionEntrySheetView: View {
    private let compositionList = sampleCompositions
    @Binding var composition: [CompositionModel]
    @Binding var compositionToEdit: CompositionModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftComposition: CompositionModel = .init()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
 
    var body: some View {
        NavigationStack {
            List {
                Section(compositionToEdit.name.isEmpty ? "New Composition" : "Edit Composition") {
                    TextField("Composition Name", text: $draftComposition.name)
                }
                
                Section("Strength") {
                    StrengthView(strength: $draftComposition.strength)
                }
                                
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
            .alert("Something went wrong",
                   isPresented: $showError) {
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
                        if (compositionToEdit.name.isEmpty) {
                            addComposition()
                        } else {
                            replaceComposition()
                        }
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
    
    private func addComposition() {
        draftComposition.name = draftComposition.name.trimmingCharacters(in: .whitespacesAndNewlines)
        composition.append(draftComposition)
    }
    
    private func replaceComposition() {
        var indexOfCompositionToReplace = -1
        
        for (index, composition) in self.composition.enumerated() {
            if (composition.id == compositionToEdit.id) {
                indexOfCompositionToReplace = index
                break
            }
        }
        
        if (indexOfCompositionToReplace != -1) {
            draftComposition.name = draftComposition.name.trimmingCharacters(in: .whitespacesAndNewlines)
            composition[indexOfCompositionToReplace] = draftComposition
        } else {
            errorMessage = "Could not replace \(compositionToEdit.getFullName())."
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        CompositionEntrySheetView(composition: .constant([.init(name: "Composition", strength: .init(amount: 10.75, unit: "ml"))]),
                                  compositionToEdit: .constant(.init()))
    }
}
