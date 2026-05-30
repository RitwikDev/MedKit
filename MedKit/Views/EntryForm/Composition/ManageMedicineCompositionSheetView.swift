//
//  ManageMedicineCompositionSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct ManageMedicineCompositionSheetView: View {
    @State var medicineComposition: [Composition]
    @State var allCompositions: [Composition]
    let compositionToEdit: Composition
    let onSave: ([Composition]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftComposition: Composition = .init()
    @State private var otherCompositions: [Composition] = []
    @State private var showSheet: Bool = false
    @State private var showUnsavedChangesConfirmationDialog: Bool = false
    
    private var isNewComposition: Bool {
        compositionToEdit.persistentIdentifier == nil
    }
    
    private var title: String {
        isNewComposition ? "New Composition" : "Edit Composition"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                addCompositionView
            }
            .onAppear { handleOnAppear(draftComposition: &draftComposition, otherCompositions: &otherCompositions) }
            .toolbar { toolbarItems }
            .environment(\.openURL, OpenURLAction { url in
                if (url.absoluteString == "app://open-other-compositions-sheet") {
                    showSheet = true
                    return .handled
                }
                
                return .systemAction
            })
            .sheet(isPresented: $showSheet) {
                OtherCompositionsSheetView(
                    otherCompositions: $otherCompositions,
                    selectedComposition: $draftComposition
                )
            }
            .sheetModifier(titled: title)
        }
    }
    
    private var addCompositionView: some View {
        Group {
            Section(title) {
                TextField("Composition Name", text: $draftComposition.name)
                    .autocorrectionDisabled()
            }
            
            StrengthSectionView(
                strengthAmount: $draftComposition.strengthAmount,
                strengthUnit: $draftComposition.strengthUnit
            )
            
            Section(content: {
                Button(isNewComposition ? "Add Composition" : "Save Composition") {
                    addOrUpdateComposition(draftComposition: &draftComposition, otherCompositions: &otherCompositions)
                }
                .disabled(disableAddButton(draftComposition: draftComposition))
            }, footer: {
                Text("Alternatively, you may choose from the compositions added to your other medicines ***[here](app://open-other-compositions-sheet)***.")
            })
        }
    }
    
    private var currentCompositionView: some View {
        Section("This Medicine's Composition") {
            if (!medicineComposition.isEmpty) {
                ForEach(medicineComposition) { composition in
                    Text(composition.fullName)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                remove(composition: composition, otherCompositions: &otherCompositions)
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
                        }
                }
            } else {
                EmptyEntryView(text: "No Composition Added")
            }
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if (compositionToEdit.equalsFullName(draftComposition) || draftComposition.name.trimmedIsEmpty) {
                        onSave(medicineComposition)
                        dismiss()
                    } else {
                        showUnsavedChangesConfirmationDialog.toggle()
                    }
                }
                .confirmationDialog(
                    "You have some unsaved changes",
                    isPresented: $showUnsavedChangesConfirmationDialog,
                    titleVisibility: .visible
                ) {
                    Button("Discard", role: .destructive) {
                        onSave(medicineComposition)
                        dismiss()
                    }
                } message: {
                    Text("Are you sure you do not want to save \(draftComposition.fullName)?")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageMedicineCompositionSheetView(
            medicineComposition: [.init(name: "Composition 1", strengthAmount: 25, strengthUnit: "mg")],
            allCompositions: [.init(name: "Composition 1", strengthAmount: 25, strengthUnit: "mg"), .init(name: "Composition 2", strengthAmount: 5, strengthUnit: "ml")],
            compositionToEdit: .init(),
            onSave: { _ in }
        )
    }
}
