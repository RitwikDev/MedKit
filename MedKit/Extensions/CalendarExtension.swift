//
//  CalendarExtension.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation

extension Calendar {
    func isDate(_ date1: Date, equalToMonthOf date2: Date) -> Bool {
        let comp1 = self.dateComponents([.year, .month], from: date1)
        let comp2 = self.dateComponents([.year, .month], from: date2)
        return comp1.year == comp2.year && comp1.month == comp2.month
    }
}
