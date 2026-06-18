//
//  OtherCompositionsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 28/05/26.
//

import SwiftUI

struct OtherCompositionsSheetView: View {
    @Binding var otherCompositions: [Ingredient]
    @Binding var selectedComposition: Ingredient
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    private var searchResults: [Ingredient] {
        if (searchText.trimmedIsEmpty) {
            return otherCompositions
        } else {
            return otherCompositions.filter { $0.name.localizedCaseInsensitiveContains(searchText.trimmed) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if (searchResults.isEmpty) {
                    EmptyEntryView(text: "No Results Found")
                } else {
                    ForEach(searchResults, id: \.self) { composition in
                        Button(composition.fullName) {
                            selectedComposition = Ingredient(
                                name: composition.name,
                                strengthAmount: composition.strengthAmount,
                                strengthUnit: composition.strengthUnit
                            )
                            dismiss()
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheetModifier(titled: "Other Compositions")
        }
        .searchable(text: $searchText)
    }
}

#Preview {
    OtherCompositionsSheetView(
        otherCompositions: .constant(
            [
                .init(name: "Composition 1", strengthAmount: 25, strengthUnit: "mg"),
                .init(name: "Composition 2", strengthAmount: 5, strengthUnit: "ml")
            ]
        ),
        selectedComposition: .constant(.init())
    )
}
