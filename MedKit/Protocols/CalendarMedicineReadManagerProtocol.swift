//
//  CalendarMedicineReadManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import Foundation

protocol CalendarMedicineReadManagerProtocol {
    func getMedicines() throws -> [CalendarMedicine]
}
