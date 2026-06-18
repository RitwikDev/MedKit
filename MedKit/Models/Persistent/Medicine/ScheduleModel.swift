//
//  ScheduleModel.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import Foundation
import SwiftData

@Model
class ScheduleModel {
    var startDate: Date?
    var endDate: Date?
    var reminderTimes: [ReminderTime]
    var repeatType: RepeatType
    var selectedDays: [Day]
    var selectedDates: [DateComponents]
    
    init(
         startDate: Date? = nil,
         endDate: Date? = nil,
         reminderTimes: [ReminderTime] = [],
         repeatType: RepeatType = .never,
         selectedDays: [Day] = [],
         selectedDates: [DateComponents] = []
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.reminderTimes = reminderTimes
        self.repeatType = repeatType
        self.selectedDays = selectedDays
        self.selectedDates = selectedDates
    }
}
