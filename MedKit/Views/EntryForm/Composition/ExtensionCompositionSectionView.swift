//
//  ExtensionCompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation

extension CompositionSectionView {
    func addNewComposition() {
        compositionToEdit = .init()
    }
    
    func deleteCompositions(at offsets: IndexSet) {
        medicineComposition.remove(atOffsets: offsets)
    }
}
