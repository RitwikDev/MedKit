//
//  DosageModel.swift
//  MedKit
//
//  Created by Rishik Dev on 04/06/26.
//

import Foundation
import SwiftUI

struct DosageModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var dosageQuantity: Float?
    var startDate: Date?
    var endDate: Date?
    var reminderTimes: [ReminderTime]
    var repeatType: RepeatType
    var selectedDays: [Day]
    var selectedDates: [DateComponents]
    
    init(
        id: UUID = UUID(),
        dosageQuantity: Float? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        reminderTimes: [ReminderTime] = [],
        repeatType: RepeatType = .never,
        selectedDays: [Day] = [],
        selectedDates: [DateComponents] = []
    ) {
        self.id = id
        self.dosageQuantity = dosageQuantity
        self.startDate = startDate
        self.endDate = endDate
        self.reminderTimes = reminderTimes
        self.repeatType = repeatType
        self.selectedDays = selectedDays
        self.selectedDates = selectedDates
    }
    
    public static func fromMedicineEntity(_ entity: MedicineEntity) -> DosageModel? {
        var dosageStruct: DosageModel? = nil
        if let dosageEntity = entity.dosage {
            
            // Decode complex binary date components
            var mappedDates: [DateComponents] = []
            if let datesData = dosageEntity.selectedDatesData,
               let decoded = try? JSONDecoder().decode([DateComponents].self, from: datesData) {
                mappedDates = decoded
            }
            
            // Extract transformable string array and map back to enums
            let rawDays = dosageEntity.selectedDays ?? []
            let mappedDays = rawDays.compactMap { Day(rawValue: $0 as? String ?? "Unknown") }
            
            // Map Reminders
            let reminderEntities = dosageEntity.reminderTimes as? Set<ReminderTimeEntity> ?? []
            let mappedReminders = reminderEntities.map { ReminderTime(id: $0.id ?? UUID(), time: $0.time ?? Date()) }.sorted { $0.time < $1.time }
            
            dosageStruct = DosageModel(
                id: dosageEntity.id ?? UUID(),
                dosageQuantity: dosageEntity.dosageQuantity,
                startDate: dosageEntity.startDate,
                endDate: dosageEntity.endDate,
                reminderTimes: mappedReminders,
                repeatType: RepeatType(rawValue: dosageEntity.repeatType ?? "") ?? .never,
                selectedDays: mappedDays,
                selectedDates: mappedDates
            )
        }
        
        return dosageStruct
    }
}

enum RepeatType: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    case never = "Never"
    case selectDays = "Select Days"
    case fortnightly = "Fortnightly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case biannually = "Biannually"
    case annually = "Annually"
    case custom = "Custom"
    
    var localizedName: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
}

enum Day: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    case sunday = "Sunday"
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    
    init?(weekdayNumber: Int) {
        switch weekdayNumber {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil // Invalid weekday
        }
    }
    
    var weekdayNumber: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    var localizedName: LocalizedStringKey {
        return LocalizedStringKey(self.rawValue)
    }
}

struct ReminderTime: Identifiable, Equatable, Hashable, Codable {
    let id: UUID
    var time: Date
    
    init(id: UUID = UUID(), time: Date) {
        self.id = id
        self.time = time
    }
}
