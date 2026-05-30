//
//  CompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionSectionView: View {
    @Binding var medicineComposition: [Composition]
    @Binding var compositionToEdit: Composition?
    
    var body: some View {
        Section("Composition") {
            ForEach(medicineComposition) { composition in
                Button(composition.fullName) {
                    compositionToEdit = composition
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: deleteCompositions)
            
            Button("Add Composition", action: addNewComposition) 
        }
    }
}

#Preview {
    Form {
        CompositionSectionView(
            medicineComposition: .constant([
                .init(name: "Ingredient 1"),
                .init(name: "Ingredient 2", strengthAmount: 10, strengthUnit: "mg")
            ]),
            compositionToEdit: .constant(.init()),
        )
    }
}
