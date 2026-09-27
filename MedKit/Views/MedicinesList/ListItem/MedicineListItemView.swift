//
//  MedicineListItemView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import CloudKit
import SwiftUI

struct MedicineListItemView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    let medicine: MedicineListItemModel
    
    var body: some View {
        Button {
            if let completeMedicine = medicineViewModel.getById(medicine.id) {
                router.navigate(to: .medicineForm(for: completeMedicine))
            }
        } label: {
            buttonLabel
        }
        .tint(.primary)
    }
    
    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(medicine.name)
                    .font(.headline)
                
                Spacer()
                
                MedicineListItemIconsView(medicine: medicine)
            }
            
            if let strengthAmount = medicine.strengthAmount,
                let strengthUnit = medicine.strengthUnit {
                Text("\(String(format: "%.3f", strengthAmount)) \(strengthUnit)")
            }
            
            MedicineListItemExpiryView(medicine: medicine)
            
            if let stock = medicine.stock {
                if (stock.unit.trimmed == "") {
                    EmptyView()
                } else {
                    MedicineListItemStockView(
                        medicineId: medicine.id,
                        stock: stock,
                        dosage: medicine.dosage,
                    )
                }
            }
            
            if (!medicine.tags.isEmpty) {
                MedicineListItemTagsView(medicine: medicine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.subheadline)
        .padding()
        .roundedRectBackground(
            colour: colorScheme == .dark ?
            Color(uiColor: .systemGray4) :
                Color(uiColor: .systemBackground)
        )
        .shadow(
            color: colorScheme == .dark ? .black :
                    .gray,
            radius: 10
        )
        .padding(.vertical, 5)
    }
}

#Preview {
    MedicineListItemView(
        medicine: MedicineListItemModel(
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
    .environment(NavigationRouter())
    .environment(MedicineViewModel())
}
