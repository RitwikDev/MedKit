//
//  ScheduleModelExtensions.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import Foundation

extension ScheduleModel {
    convenience init(from schedule: Schedule) {
        self.init(
            startDate: schedule.startDate,
            endDate: schedule.endDate,
            reminderTimes: schedule.reminderTimes,
            repeatType: schedule.repeatType,
            selectedDay: schedule.selectedDay,
            selectedDates: schedule.selectedDates,
        )
    }
}
