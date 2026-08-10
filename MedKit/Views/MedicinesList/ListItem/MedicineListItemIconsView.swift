//
//  MedicineListItemIconsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListItemIconsView: View {
    let medicine: MedicineListItemModel
    
    var body: some View {
        HStack {
            if (medicine.isExpiringSoon) {
                Image(systemName: "clock")
            }
            
            if (medicine.isRunningOutOfStock) {
                Image(systemName: "exclamationmark.triangle")
            }
        }
        .fontWeight(.bold)
        .foregroundStyle(.orange)
    }
}

#Preview {
    MedicineListItemIconsView(
        medicine: .init(
            id: UUID(),
            name: "Medicine Name",
            strengthAmount: 10,
            strengthUnit: "mg",
            stock: nil,
            dosage: nil,
            expiryDate: .now,
            tags: [],
        )
    )
}
