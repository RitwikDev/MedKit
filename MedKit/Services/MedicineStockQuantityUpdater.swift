//
//  MedicineStockQuantityUpdater.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import Foundation

class MedicineStockQuantityUpdater
{
    public static func update(isIncrement: Bool, quantity: Float, dosage: DosageModel?) -> Float {
        var step = dosage?.dosageQuantity ?? 1
        step = isIncrement ? step : -1 * step
        
        return max(0, quantity + step)
    }
}
