//
//  MedicineListSortOptionsEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import Foundation

enum MedicineListSortOptionsEnum: String, Codable, CaseIterable, Identifiable {
    case nameAscending = "Name, Ascending"
    case nameDescending = "Name, Descending"
    case expiryAscending = "Expiry, Ascending"
    case expiryDescending = "Expiry, Descending"
    case stockAscending = "Stock Quantity, Ascending"
    case stockDescending = "Stock Quantity, Descending"
    
    var id: Self { self }
}
