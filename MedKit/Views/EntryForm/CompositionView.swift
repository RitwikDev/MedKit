//
//  CompositionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionView: View {
    @Binding var composition: [CompositionModel]
    @Binding var compositionToEdit: CompositionModel
    let buttonAction: () -> Void
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        List {
            ForEach($composition) { $composition in
                HStack {
                    Button(composition.getFullName()) {
                        compositionToEdit = composition
                        buttonAction()
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    RoundedTintedButtonView(buttonAction: {
                        compositionToEdit = composition
                        showDeleteConfirmation.toggle()
                    },
                                            title: "Delete \(composition.name)",
                                            systemImage: "xmark",
                                            tintColor: .red)
                }
            }
            
            Button("Add Composition") {
                compositionToEdit = .init()
                buttonAction()
            }
        }
        .alert("Something went wrong",
               isPresented: $showError) {
            Button("Dismiss") { }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Delete \(compositionToEdit.getFullName())?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete") {
                withAnimation {
                    deleteComposition()
                }
            }
            Button("Cancel") { }
        }
    }
    
    private func deleteComposition() {
        var indexOfCompositionToDelete = -1
        
        for (index, composition) in self.composition.enumerated() {
            if (composition.id == compositionToEdit.id) {
                indexOfCompositionToDelete = index
                break
            }
        }
        
        if (indexOfCompositionToDelete != -1) {
            composition.remove(at: indexOfCompositionToDelete)
        } else {
            errorMessage = "Could not delete \(compositionToEdit.getFullName())."
            showError = true
        }
    }
}

#Preview {
    CompositionView(composition: .constant([.init(name: "Ingredient 1", strength: nil), .init(name: "Ingredient 2", strength: StrengthModel(amount: 10, unit: "mg"))]),
                    compositionToEdit: .constant(.init()),
                    buttonAction: { })
}
