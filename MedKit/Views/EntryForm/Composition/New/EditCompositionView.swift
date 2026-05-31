//
//  EditCompositionView.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import SwiftUI

struct EditCompositionView: View {
    let composition: Composition
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineViewModel.self) private var medicineViewModel
    @State private var draftComposition: Composition
    
    init(composition: Composition) {
        self.composition = composition
        self._draftComposition = State(initialValue: composition)
    }
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $draftComposition.name)
            }
            
            StrengthSectionView(
                strengthAmount: $draftComposition.strengthAmount,
                strengthUnit: $draftComposition.strengthUnit
            )
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    medicineViewModel.upsertComposition(draftComposition)
                    dismiss()
                }
                .disabled(!draftComposition.isValid())
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditCompositionView(
            composition: Composition(
                name: "Composition Name",
                strengthAmount: 500,
                strengthUnit: "mcg"
            )
        )
    }
    .environment(MedicineViewModel())
}
