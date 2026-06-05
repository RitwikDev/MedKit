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
        CompositionFormView(
            composition: $draftComposition,
            compositions: medicineViewModel.medicine.composition,
            isInputDisabled: false
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    medicineViewModel.upsertComposition(draftComposition)
                    dismiss()
                }
                .disabled(!isValid())
            }
        }
        .navigationTitle("Edit \(composition.name)")
    }
    
    private func isValid() -> Bool {
        let isDuplicate = medicineViewModel.medicine.composition.contains { $0.id != draftComposition.id && $0.equalsName(draftComposition) }

        if (!draftComposition.isValid() || isDuplicate) {
            return false
        }
        return true
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
