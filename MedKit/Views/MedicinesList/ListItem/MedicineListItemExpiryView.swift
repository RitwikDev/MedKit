//
//  MedicineListItemExpiryView.swift
//  MedKit
//
//  Created by Ritwik Dev on 08/08/26.
//

import SwiftUI

struct MedicineListItemExpiryView: View {
    let medicine: MedicineListItemModel
    
    var body: some View {
        HStack {
            Text("Expiry Date:")
            
            if let expiryDate = medicine.expiryDate {
                Text(expiryDate, format: Date.FormatStyle(date: .abbreviated, time: .omitted))
            } else {
                Text("N/A")
            }
        }
    }
}

#Preview {
    MedicineListItemExpiryView(
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
            isShared: false,
        )
    )
}
