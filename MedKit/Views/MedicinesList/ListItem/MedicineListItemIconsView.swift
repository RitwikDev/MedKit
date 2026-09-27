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
            if (medicine.isShared) {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.blue)
            }
            
            if (medicine.isOnShoppingList) {
                Image(systemName: "cart")
                    .foregroundStyle(.blue)
            }
            
            if (medicine.isExpiringSoon) {
                Image(systemName: "clock")
                    .foregroundStyle(.orange)
            }
            
            if (medicine.isRunningOutOfStock) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.orange)
            }
        }
        .fontWeight(.bold)
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
            isOnShoppingList: false,
            isShared: true
        )
    )
}
