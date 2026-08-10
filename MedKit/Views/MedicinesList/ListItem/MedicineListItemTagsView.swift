//
//  MedicineListItemTagsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 08/08/26.
//

import SwiftUI

struct MedicineListItemTagsView: View {
    let medicine: MedicineListItemModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(medicine.tags) { tag in
                    Text(tag.value)
                        .padding(5)
                        .foregroundStyle(.white)
                        .roundedRectBackground(colour: .blue)
                }
            }
        }
    }
}

#Preview {
    MedicineListItemTagsView(
        medicine: .init(
            id: UUID(),
            name: "Medicine Name",
            strengthAmount: 10,
            strengthUnit: "mg",
            stock: nil,
            dosage: nil,
            expiryDate: .now,
            tags: [
                Tag(value: "Fever"),
                Tag(value: "Chills"),
                Tag(value: "Stomach ache"),
            ],
        )
    )
}
