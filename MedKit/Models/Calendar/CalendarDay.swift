//
//  CalendarDay.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let dayNumber: Int
}
