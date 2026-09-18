//
//  NotificationManager.swift
//  MedKit
//
//  Created by Rishik Dev on 10/08/26.
//

import CoreData
import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    static let dataDidChangeNotification = Notification.Name("NotificationManagerDataDidChange")
    
    private let categoryIdentifier = "MEDICINE_REMINDER"
    private let actionTaken = "ACTION_TAKEN"
    private let actionRemind = "ACTION_REMIND"
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests authorisation to deliver notifications
    func requestAuthorisation() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.registerCategories()
            } else if let error = error {
                print("Notification authorisation denied: \(error.localizedDescription)")
            }
        }
    }
    
    /// Registers all notification categories
    func registerCategories() {
        let takenAction = UNNotificationAction(
            identifier: actionTaken,
            title: "Mark As Taken",
            options: []
        )
        
        let remindAction = UNNotificationAction(
            identifier: actionRemind,
            title: "Remind Me in 15 Minutes",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [takenAction, remindAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    /// Schedules notifications for the given medicine using deterministic identifiers
    ///
    /// - Parameter medicine: Medicine for which the notification needs to be scheduled
    ///
    func scheduleInitialNotification(for medicine: Medicine) throws {
        Task {
            let centre = UNUserNotificationCenter.current()
            
            await removePendingNotificationRequests(for: medicine.id)
            
            // Prepare new notification content
            let content = UNMutableNotificationContent()
            content.title = "Time to Take \(medicine.name)."
            
            var bodyText = "Please Take Your Medication."
            
            if let dosage = medicine.dosage?.dosageQuantity {
                let unit = medicine.stock?.unit ?? ""
                bodyText = "Take \(dosage) \(unit)."
            }
            
            content.body = bodyText
            content.sound = .default
            content.categoryIdentifier = categoryIdentifier
            content.userInfo = ["medicineId": medicine.id.uuidString, "medicineName": medicine.name]
            
            guard let dosage = medicine.dosage,
                  let nextDosageDate = MedicineDosageHelper.getNextDosageDate(for: dosage)
            else { return }

            let baseId = medicine.id.uuidString

            // Irregular Schedules
            let irregularTypes: [RepeatType] = [.custom, .fortnightly, .quarterly, .biannually]
            if irregularTypes.contains(dosage.repeatType) {
                var components = Calendar.current.dateComponents([.year, .month, .day], from: nextDosageDate)

                for reminderTime in dosage.reminderTimes {
                    let notificationIdentifier = "\(baseId)-\(reminderTime.id)-irregular"
                    
                    let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderTime.time)
                    components.hour = timeComponents.hour
                    components.minute = timeComponents.minute
                    
                    if let initialFireDate = Calendar.current.date(from: components) {
                        scheduleSingleNotification(
                            content: content,
                            date: initialFireDate,
                            notificationIdentifier: notificationIdentifier
                        )
                    }
                }
                return
            }
            
            // Regular Schedules (Native iOS Repeats)
            for reminder in dosage.reminderTimes {
                let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
                
                var triggerComponents = DateComponents()
                triggerComponents.hour = timeComponents.hour
                triggerComponents.minute = timeComponents.minute
                
                switch dosage.repeatType {
                case .selectDays:
                    for day in dosage.selectedDays {
                        triggerComponents.weekday = day.weekdayNumber
                        
                        let notificationIdentifier = "\(baseId)-\(reminder.id)-day-\(day.weekdayNumber)"
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                        try await centre.add(request)
                    }
                case .monthly:
                    triggerComponents.day = Calendar.current.component(.day, from: nextDosageDate)
                    let notificationIdentifier = "\(baseId)-\(reminder.id)-monthly"
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    try await centre.add(request)
                case .annually:
                    triggerComponents.month = Calendar.current.component(.month, from: nextDosageDate)
                    triggerComponents.day = Calendar.current.component(.day, from: nextDosageDate)
                    let notificationIdentifier = "\(baseId)-\(reminder.id)-annually"
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    try await centre.add(request)
                case .never:
                    triggerComponents.year = Calendar.current.component(.year, from: nextDosageDate)
                    triggerComponents.month = Calendar.current.component(.month, from: nextDosageDate)
                    triggerComponents.day = Calendar.current.component(.day, from: nextDosageDate)
                    let notificationIdentifier = "\(baseId)-\(reminder.id)-never"
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                    try await centre.add(request)
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let medicineIdString = userInfo["medicineId"] as? String,
              let medicineId = UUID(uuidString: medicineIdString) else {
            completionHandler()
            return
        }
        
        switch response.actionIdentifier {
        case actionTaken:
            processMedicineTaken(for: medicineId)
        case actionRemind:
            remindAgainIn15Minutes(originalContent: response.notification.request.content)
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Get Pending Notifications
    
    func getPendingNotificationRequests() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Remove Pending Notifications
    
    func removePendingNotificationRequests(for medicineId: UUID) async {
        let pendingRequests = await getPendingNotificationRequests()
        
        let identifiersToCancel = pendingRequests.filter {
            ($0.content.userInfo["medicineId"] as? String) == medicineId.uuidString
        }.map { $0.identifier }
        
        removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllPendingNotificationRequests() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Background Processing
    
    private func processMedicineTaken(for medicineId: UUID) {
        do {
            var medicine = try MedicineReadManager.shared.fetchById(medicineId)
            
            guard let stock = medicine.stock,
                  let dosage = medicine.dosage
            else { return }
            
            let newQuantity = MedicineStockQuantityUpdater.update(
                isIncrement: false,
                quantity: stock.quantity,
                dosage: dosage,
            )
            
            medicine.stock?.quantity = newQuantity
            
            try MedicineWriteManager.shared.save(medicine)
            
            NotificationCenter.default.post(name: Self.dataDidChangeNotification, object: nil)
            
        } catch {
            print("Failed to process medicine in the background: \(error)")
        }
    }
    
    private func scheduleNextIrregularNotificationIfNeeded(for entity: MedicineEntity, dosage: DosageModel) {
        let irregularTypes: [RepeatType] = [.custom, .fortnightly, .quarterly, .biannually]
        guard irregularTypes.contains(dosage.repeatType),
              let firstReminder = dosage.reminderTimes.first else { return }
        
        let calendar = Calendar.current
        let now = Date()
        var nextFireDate: Date?
        
        switch dosage.repeatType {
        case .fortnightly:
            nextFireDate = calendar.date(byAdding: .day, value: 14, to: now)
        case .quarterly:
            nextFireDate = calendar.date(byAdding: .month, value: 3, to: now)
        case .biannually:
            nextFireDate = calendar.date(byAdding: .month, value: 6, to: now)
        case .custom:
            let validDates = dosage.selectedDates.compactMap { calendar.date(from: $0) }
            nextFireDate = validDates.filter { $0 > now }.min()
        default:
            return
        }
        
        guard let validNextDate = nextFireDate else { return }
        
        if let endDate = dosage.endDate, validNextDate > endDate {
            return
        }
        
        var nextComponents = calendar.dateComponents([.year, .month, .day], from: validNextDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: firstReminder.time)
        
        nextComponents.hour = timeComponents.hour
        nextComponents.minute = timeComponents.minute
        
        guard let finalDate = calendar.date(from: nextComponents) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to take \(entity.name ?? "your medicine")"
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        let medIdString = entity.id?.uuidString ?? UUID().uuidString
        content.userInfo = ["medicineId": medIdString, "medicineName": entity.name ?? ""]
        
        // Use a deterministic string instead of saving to Core Data
        let notificationIdentifier = "\(medIdString)-\(firstReminder.id)-irregular"
        
        scheduleSingleNotification(content: content, date: finalDate, notificationIdentifier: notificationIdentifier)
    }
    
    private func scheduleSingleNotification(
        content: UNMutableNotificationContent,
        date: Date,
        notificationIdentifier: String
    ) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func remindAgainIn15Minutes(originalContent: UNNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 900, repeats: false)
        
        // Prevent stacking duplicate snoozes by using a deterministic ID
        let medId = (originalContent.userInfo["medicineId"] as? String) ?? UUID().uuidString
        let identifier = "\(medId)-snooze"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: originalContent,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
