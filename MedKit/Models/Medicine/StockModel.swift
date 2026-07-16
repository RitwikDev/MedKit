//
//  StockModel.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/07/26.
//

import Foundation

struct StockModel: Equatable, Hashable {
    let id: UUID
    var quantity: Float
    var unit: String
    var endDate: Date
    
    init(
        id: UUID = UUID(),
        quantity: Float = 0,
        unit: String = "",
        endDate: Date = .distantFuture,
    ) {
        self.id = id
        self.quantity = quantity
        self.unit = unit
        self.endDate = endDate
    }
    
    public static func fromMedicineEntity(_ medicine: MedicineEntity) -> StockModel {
        if let stock = medicine.stock {
            return .init(
                id: stock.id ?? UUID(),
                quantity: stock.quantity,
                unit: stock.unit ?? "",
                endDate: stock.endDate ?? .distantFuture,
            )
        }
        
        return .init()
    }
}
