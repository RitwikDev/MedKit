//
//  CompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionSectionView: View {
    @Binding var compositionList: [Composition]
    @Binding var compositionToEdit: Composition?
    
    var body: some View {
        Section(
            content: {
                if compositionList.isEmpty {
                    EmptyEntryView(text: "No composition added")
                } else {
                    ForEach(compositionList) { composition in
                        Button(composition.getFullName()) {
                            compositionToEdit = composition
                        }
                        .foregroundStyle(.primary)
                    }
                    .onDelete(perform: deleteCompositions)
                }
            },
            header: {
                HStack {
                    Text("Composition")
                    Spacer()
                    RoundedTintedButtonView(
                        title: "Add",
                        systemImage: "plus",
                        tintColor: .blue,
                        buttonAction: addNewComposition,
                    )
                }
            },
        )
    }
    
    private func addNewComposition() {
        compositionToEdit = .init()
    }
    
    private func deleteCompositions(at offsets: IndexSet) {
        compositionList.remove(atOffsets: offsets)
    }
}

#Preview {
    CompositionSectionView(
        compositionList: .constant([
            .init(name: "Ingredient 1"),
            .init(name: "Ingredient 2", strengthAmount: 10, strengthUnit: "mg")
        ]),
        compositionToEdit: .constant(.init()),
    )
}
