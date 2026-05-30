//
//  NavigationPathEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import Foundation
import SwiftUI

enum NavigationPathEnum: Hashable {
    case MedicineList
    case MedicineForm(for: Medicine)
    case MedicineComposition(for: Composition)
    case MedicineCustomFields
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .MedicineList:
            MedicineListView()
        case .MedicineForm(let medicine):
            MedicineFormView(medicine: medicine)
        default: MedicineListView()
        }
    }
}
