//
//  CalendarMedicine.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation

struct CalendarMedicine {
    let id: UUID
    let name: String
    let expiryDate: Date?
    let dosage: DosageModel?
    let stock: StockModel?
}
