//
//  MedicineListItemStockView.swift
//  MedKit
//
//  Created by Ritwik Dev on 08/08/26.
//

import SwiftUI

struct MedicineListItemStockView: View {
    let medicineId: UUID
    let stock: StockModel
    let dosage: DosageModel?
    
    var body: some View {
        HStack {
            decrementButton
            
            Text("\(String(format: "%.2f", stock.quantity)) \(stock.unit)")
                .frame(maxWidth: .infinity)
                .fontWeight(.heavy)
            
            incrementButton
        }
        .frame(maxWidth: .infinity)
        .padding(8)
//        .background((Color(uiColor: .systemBackground)).shadow(.inner(radius: 10)))
        .background((Color(uiColor: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))).shadow(.inner(radius: 10)))
        .foregroundStyle(.white)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    private var decrementButton: some View {
        Button(
            action: { updateStock(isIncrement: false) },
            label: {
                Image(systemName: "minus")
                    .frame(width: 44, height: 44)
                    .roundedRectBackground(colour: .blue)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 10)
            }
        )
    }
    
    private var incrementButton: some View {
        Button(
            action: { updateStock(isIncrement: true) },
            label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
                    .roundedRectBackground(colour: .blue)
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 10)
            }
        )
    }
    
    private func updateStock(isIncrement: Bool) -> Void {
        let newQuantity = MedicineStockQuantityUpdater.update(
            isIncrement: isIncrement,
            quantity: stock.quantity,
            dosage: dosage,
        )
        
        MedicineListItemManager.shared.updateStockQuantity(
            medicineId: medicineId,
            quantity: newQuantity,
            dosage: dosage,
        )
    }
}

#Preview {
    MedicineListItemStockView(
        medicineId: UUID(),
        stock: .init(
            quantity: 10,
            unit: "Tablet",
            endDate: .now.advanced(by: 5)
        ),
        dosage: nil,
    )
}
