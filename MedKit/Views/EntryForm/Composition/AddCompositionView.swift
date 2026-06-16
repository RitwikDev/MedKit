//
//  AddCompositionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct AddCompositionView: View {
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    var body: some View {
        BatchEntryView(
            title: "Add Composition",
            initialItems: [Composition()],
            newItemProvider: { Composition() },
            
            // 2. Explicitly type the array in the closure to anchor the compiler
            isDataValid: { (items: [Composition]) in
                isValid(items)
            },
            
            // 3. Explicitly type the save closure as well
            onSave: { (finalCompositions: [Composition]) in
                medicineViewModel.addCompositions(finalCompositions)
            }
            
        ) { compositionBinding, newCompositions, isInputDisabled in
            let allCompositions = medicineViewModel.medicine.composition + newCompositions
            
            CompositionFormView(
                composition: compositionBinding,
                compositions: allCompositions,
                isInputDisabled: isInputDisabled
            )
        }
    }
    
    private func isValid(_ newCompositions: [Composition]) -> Bool {
        let allCompositions = medicineViewModel.medicine.composition + newCompositions
        
        for newComposition in newCompositions {
            let isDuplicate = allCompositions.contains { $0.id != newComposition.id && $0.equalsName(newComposition) }
            if (!newComposition.isValid() || isDuplicate) {
                return false
            }
        }
        return true
    }
}

#Preview {
    NavigationStack {
        AddCompositionView()
            .environment(MedicineViewModel())
    }
}
