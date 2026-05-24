//
//  QuantitySectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct QuantitySectionView: View {
    @Bindable var medicine: MedicineModel
    
    var body: some View {
        Section("Quantity") {
            Stepper(medicine.quantity.description, value: $medicine.quantity, in: 0...100)
        }
    }
}

//#Preview {
//    QuantitySectionView(medicine: .constant(.init()))
//}
