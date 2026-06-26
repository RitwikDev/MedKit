//
//  MedicineEditorViewModelExtension.swift
//  MedKit
//
//  Created by Rishik Dev on 25/06/26.
//

import Foundation

extension MedicineEditorViewModel: Hashable {
    nonisolated static func == (lhs: MedicineEditorViewModel, rhs: MedicineEditorViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
