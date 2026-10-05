//
//  ShoppingListItemView.swift
//  MedKit
//
//  Created by Rishik Dev on 03/10/26.
//

import SwiftUI

struct ShoppingListItemView: View {
    let medicine: Medicine
    
    private var reasons: [String] {
        ShoppingListPopulationHelper.getReason(stockEndDate: medicine.stock?.endDate, expiryDate: medicine.expiryDate, stockQuantity: medicine.stock?.quantity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medicine.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading) {
                if let stock = medicine.stock {
                    if stock.quantity > 0 {
                        Text("Stock running low (\(Int(stock.quantity)) \(stock.unit) remaining)")
                    } else {
                        Text("Stockout")
                    }
                }
                
                if let expiryDate = medicine.expiryDate {
                    if Calendar.current.startOfDay(for: expiryDate) <= Calendar.current.startOfDay(for: .now) {
                        Text("Expired on \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                    } else {
                        Text("Expiring on \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(reasons, id: \.self) { reason in
                        Text(reason)
                            .font(.subheadline)
                            .padding(5)
                            .foregroundStyle(.white)
                            .roundedRectBackground(colour: .blue)
                    }
                }
            }
        }
        .tag(medicine.id)
    }
}

#Preview {
    ShoppingListItemView(medicine: .init())
}
