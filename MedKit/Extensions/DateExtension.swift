//
//  DateExtension.swift
//  MedKit
//
//  Created by Ritwik Dev on 26/07/26.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

extension Date {
    /// Returns the first occurrence of a specific weekday starting from (or after) this date.
    /// - Parameters:
    ///   - weekday: The target `Weekday` enum value.
    ///   - inclusive: If true and the current date matches the weekday, returns this date.
    func nextWeekday(_ weekday: Weekday, inclusive: Bool = true) -> Date? {
        let calendar = Calendar.current
        var targetComponents = DateComponents()
        targetComponents.weekday = weekday.rawValue
        
        if (inclusive) {
            let currentWeekday = calendar.component(.weekday, from: self)
            if currentWeekday == weekday.rawValue {
                return calendar.startOfDay(for: self)
            }
        }
        
        return calendar.nextDate(
            after: self,
            matching: targetComponents,
            matchingPolicy: .nextTime,
            direction: .forward
        )
    }
}
