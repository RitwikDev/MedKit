//
//  ExtensionCompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation
import SwiftUI

extension ManageMedicineCompositionSheetView {
    func handleOnAppear(draftComposition: inout Composition, otherCompositions: inout [Composition]) {
        draftComposition = compositionToEdit
        filterCompositions(otherCompositions: &otherCompositions)
    }
    
    func remove(composition: Composition, otherCompositions: inout [Composition]) {
        withAnimation {
            medicineComposition.removeAll { $0.equalsId(composition) }
            filterCompositions(otherCompositions: &otherCompositions)
        }
    }
    
    func filterCompositions(otherCompositions: inout [Composition]) {
        let medicineCompositionSet = Set(medicineComposition.map { $0.fullName })
        otherCompositions = allCompositions.filter { !medicineCompositionSet.contains($0.fullName) }
    }
    
    func addOrUpdateComposition(draftComposition: inout Composition, otherCompositions: inout [Composition]) {
        let trimmedDraftCompositionName = draftComposition.name.trimmed
        guard !trimmedDraftCompositionName.isEmpty else { return }
        
        let newComposition = Composition(
            name: trimmedDraftCompositionName,
            strengthAmount: draftComposition.strengthAmount,
            strengthUnit: draftComposition.strengthUnit?.trimmed
        )
        
        allCompositions.append(newComposition)
        
        if let index = medicineComposition.firstIndex(where: { $0.equalsFullName(newComposition) }) {
            medicineComposition[index] = newComposition
        } else {
            medicineComposition.append(newComposition)
        }
        
        filterCompositions(otherCompositions: &otherCompositions)
        draftComposition = .init()
    }
    
    func disableAddButton(draftComposition: Composition) -> Bool {
        let isDraftCompositionNotValid = !draftComposition.isValid()
        let hasNoChanges = draftComposition.equalsFullName(compositionToEdit)
        let isPresentInMedicine = medicineComposition.first(where: { $0.equalsFullName(draftComposition) }) != nil

        return isDraftCompositionNotValid || hasNoChanges || isPresentInMedicine
    }
}
