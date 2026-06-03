//
//  NavigationPathEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import Foundation
import SwiftUI

enum NavigationPathEnum: Hashable {
    case medicineForm
    case addComposition
    case editComposition(for: Composition)
    case manageMedicineTags
    case medicineCustomFields
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .medicineForm:
            MedicineFormView()
        case .addComposition:
            AddCompositionView()
        case .editComposition(let composition):
            EditCompositionView(composition: composition)
        case .manageMedicineTags:
            ManageMedicineTagsView()
        default: MedicineListView()
        }
    }
}
