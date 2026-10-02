//
//  NotificationManager.swift
//  MedKit
//
//  Created by Rishik Dev on 10/08/26.
//

import CoreData
import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, NotificationManagerProtocol {
    
    static let shared = NotificationManager()
    static let dataDidChangeNotification = Notification.Name("NotificationManagerDataDidChange")
    static let notificationTappedNotification = Notification.Name("NotificationManagerNotificationTapped")
    static let shareProcessingStarted = Notification.Name("NotificationManagerShareProcessingStarted")
    static let shareProcessingFinished = Notification.Name("NotificationManagerShareProcessingFinished")
    
    private let categoryIdentifier = "MEDICINE_REMINDER"
    private let actionTaken = "ACTION_TAKEN"
    private let actionRemind = "ACTION_REMIND"
    
    private let inventoryCategoryIdentifier = "INVENTORY_REMINDER"

    
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
            title: "Mark as Taken",
            options: []
        )
        
        let remindAction = UNNotificationAction(
            identifier: actionRemind,
            title: "Remind Me in 15 Minutes",
            options: []
        )
        
        let medicineReminderCategory = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [takenAction, remindAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        

        
        let inventoryCategory = UNNotificationCategory(
            identifier: inventoryCategoryIdentifier,
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([medicineReminderCategory, inventoryCategory])
    }
    
    /// Schedules notifications for the given medicine using deterministic identifiers
    ///
    /// - Parameter medicine: Medicine for which the notification needs to be scheduled
    ///
    func scheduleInitialNotification(for medicine: Medicine) throws {
        Task {
            do {
                let centre = UNUserNotificationCenter.current()
                
                await removePendingNotificationRequests(for: medicine.id)
                await scheduleInventoryNotifications(for: medicine)
                
                // Prepare new notification content
                let content = UNMutableNotificationContent()
                content.title = String(localized: "Time to take \(medicine.name)")
                
                var bodyText = String(localized: "Please Take Your Medication.")
                
                if let dosage = medicine.dosage?.dosageQuantity {
                    let unit = medicine.stock?.unit ?? ""
                    let formattedDosage = dosage.formatted(.number)
                    bodyText = String(localized: "Take \(formattedDosage) \(unit).")
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
                    case .daily:
                        let notificationIdentifier = "\(baseId)-\(reminder.id)-daily"
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
                        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                        try await centre.add(request)
                    default:
                        break
                    }
                }
            } catch {
                print("Failed scheduling initial notification: \(error)")
            }
        }
    }
    
    private func scheduleInventoryNotifications(for medicine: Medicine) async {
        let baseId = medicine.id.uuidString
        let calendar = Calendar.current
        let now = Date()
        
        // Remove existing inventory notifications first
        removePendingNotificationRequests(withIdentifiers: ["\(baseId)-low-stock", "\(baseId)-expiring"])
        
        if medicine.isOnShoppingList {
            return
        }
        
        // Extract preferred hour and minute from first reminder, default to 9:00 AM
        var preferredHour = 9
        var preferredMinute = 0
        if let firstReminder = medicine.dosage?.reminderTimes.first {
            preferredHour = calendar.component(.hour, from: firstReminder.time)
            preferredMinute = calendar.component(.minute, from: firstReminder.time)
        }
        
        let injectTime = { (date: Date) -> Date? in
            var comps = calendar.dateComponents([.year, .month, .day], from: date)
            comps.hour = preferredHour
            comps.minute = preferredMinute
            return calendar.date(from: comps)
        }

        // 1. Stock Out
        if let stockOutDate = MedicineStockEndDateCalculator.calculate(stock: medicine.stock, dosage: medicine.dosage) {
            if let targetDate = calendar.date(byAdding: .day, value: -7, to: stockOutDate), 
               let triggerDate = injectTime(targetDate), triggerDate > now {
                let content = UNMutableNotificationContent()
                content.title = String(localized: "\(medicine.name) is running low")
                content.body = String(localized: "You will run out of \(medicine.name) in about a week.")
                content.sound = .default
                content.categoryIdentifier = inventoryCategoryIdentifier
                content.userInfo = ["medicineId": baseId, "medicineName": medicine.name]
                
                scheduleSingleNotification(content: content, date: triggerDate, notificationIdentifier: "\(baseId)-low-stock")
            }
        }
        
        // 2. Expiry
        if let expiryDate = medicine.expiryDate {
            if let targetDate = calendar.date(byAdding: .day, value: -7, to: expiryDate),
               let triggerDate = injectTime(targetDate), triggerDate > now {
                let content = UNMutableNotificationContent()
                content.title = String(localized: "\(medicine.name) is expiring soon")
                content.body = String(localized: "\(medicine.name) expires in one week.")
                content.sound = .default
                content.categoryIdentifier = inventoryCategoryIdentifier
                content.userInfo = ["medicineId": baseId, "medicineName": medicine.name]
                
                scheduleSingleNotification(content: content, date: triggerDate, notificationIdentifier: "\(baseId)-expiring")
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
        
        Task { @MainActor in
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                NotificationCenter.default.post(
                    name: Self.notificationTappedNotification,
                    object: nil,
                    userInfo: ["medicineId": medicineId]
                )
            case actionTaken:
                await processMedicineTaken(for: medicineId, deliveredDate: response.notification.date)
            case actionRemind:
                remindAgainIn15Minutes(originalContent: response.notification.request.content)
            default:
                break
            }
            
            completionHandler()
        }
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
    
    @MainActor
    private func processMedicineTaken(for medicineId: UUID, deliveredDate: Date) async {
        do {
            let localID = await GlobalDataManager.shared.fetchCurrentRecordName() ?? "You"
            var medicine = try MedicineReadManager.shared.fetchById(medicineId)
            
            guard let stock = medicine.stock,
                  let dosage = medicine.dosage
                    else { return }
            
            let newQuantity = MedicineStockQuantityUpdater.update(
                isIncrement: false,
                quantity: stock.quantity,
                dosage: dosage
            )
            
            medicine.stock?.quantity = newQuantity
            
            let stockEndDate = MedicineStockEndDateCalculator.calculate(stock: medicine.stock, dosage: dosage)
            medicine.stock?.endDate = stockEndDate ?? .distantFuture
            
            let wasOnShoppingList = medicine.isOnShoppingList
            if ShoppingListPopulationHelper.shouldPopulate(stockEndDate: stockEndDate, expiryDate: medicine.expiryDate, stockQuantity: medicine.stock?.quantity) {
                medicine.isOnShoppingList = true
                if !wasOnShoppingList {
                    await self.scheduleImmediateShoppingListNotification(for: medicine)
                }
            }
            
            // Add a DoseLog so the calendar agenda reflects this
            var nextLogs = medicine.doseLogs
            let calendar = Calendar.current
            var eventComponents = calendar.dateComponents([.year, .month, .day], from: deliveredDate)
            
            let targetHour = calendar.component(.hour, from: deliveredDate)
            let targetMinute = calendar.component(.minute, from: deliveredDate)
            
            let matchedReminder = dosage.reminderTimes.min(by: {
                let h1 = calendar.component(.hour, from: $0.time)
                let m1 = calendar.component(.minute, from: $0.time)
                let h2 = calendar.component(.hour, from: $1.time)
                let m2 = calendar.component(.minute, from: $1.time)
                
                let diff1 = abs((h1 * 60 + m1) - (targetHour * 60 + targetMinute))
                let diff2 = abs((h2 * 60 + m2) - (targetHour * 60 + targetMinute))
                
                return diff1 < diff2
            })
            
            if let matchedReminder = matchedReminder {
                eventComponents.hour = calendar.component(.hour, from: matchedReminder.time)
                eventComponents.minute = calendar.component(.minute, from: matchedReminder.time)
                
                if let finalDate = calendar.date(from: eventComponents) {
                    if let idx = nextLogs.firstIndex(where: { calendar.isDate($0.date, equalTo: finalDate, toGranularity: .minute) }) {
                        nextLogs[idx].isTaken = true
                        nextLogs[idx].takenByUserName = localID
                    } else {
                        nextLogs.append(DoseLogModel(date: finalDate, isTaken: true, takenByUserName: localID))
                    }
                }
            }
            medicine.doseLogs = nextLogs
            
            try MedicineWriteManager.shared.save(medicine)
            NotificationCenter.default.post(name: Self.dataDidChangeNotification, object: nil)
            
            await scheduleInventoryNotifications(for: medicine)
            
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
        content.title = String(localized: "Time to take \(entity.name ?? "your medicine")")
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
    private func scheduleImmediateShoppingListNotification(for medicine: Medicine) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Stock is running low")
        content.body = String(localized: "Added \(medicine.name) to your shopping list.")
        content.sound = .default
        
        content.userInfo = ["medicineId": medicine.id.uuidString, "medicineName": medicine.name]
        
        let medIdString = medicine.id.uuidString
        let notificationIdentifier = "\(medIdString)-auto-added"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
