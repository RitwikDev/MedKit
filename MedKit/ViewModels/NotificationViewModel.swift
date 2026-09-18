//
//  NotificationViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 21/08/26.
//

import Foundation
import UserNotifications

@Observable
@MainActor
class NotificationViewModel {
    let notificationManager: NotificationManager
    var notificationRequests: [UNNotificationRequest] = []
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    /// Requests authorisation to deliver notifications
    func requestAuthorisation() {
        notificationManager.requestAuthorisation()
    }
    
    /// Registers all notification categories
    func registerCategories() {
        notificationManager.registerCategories()
    }
    
    /// Schedules notifications for the given medicine
    ///
    /// - Parameter medicine: Medicine for which the notification needs to be scheduled
    ///
    func scheduleInitialNotification(for medicine: Medicine) {
        do {
            try notificationManager.scheduleInitialNotification(for: medicine)
        } catch {
            print("Error scheduling initial notification: \(error)")
        }
    }
    
    /// Returns all pending notification requests made by the application
    ///
    func getPendingNotificationRequests() async {
        self.notificationRequests = await notificationManager.getPendingNotificationRequests()
            .sorted {
                let titleComparison = $0.content.title.localizedCaseInsensitiveCompare(
                    $1.content.title
                )
                
                if titleComparison != .orderedSame {
                    return titleComparison == .orderedAscending
                }
                
                let date1 = nextTriggerDate(for: $0)
                let date2 = nextTriggerDate(for: $1)
                
                return (date1 ?? .distantFuture) < (date2 ?? .distantFuture)
            }
    }
    
    /// Removes the pending notifications associated with the given medicineId
    ///  
    /// - Parameter medicineId: Id of the medicine whose notifications have to be removed
    ///  
    func removePendingNotificationRequests(for medicineId: UUID) {
        Task {
            await notificationManager.removePendingNotificationRequests(for: medicineId)
        }
    }
    
    /// Removes the pending notifications associated with the given identifiers
    ///
    /// - Parameter identifiers: An array of `String` notification identifiers
    ///
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        notificationManager.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Removes all pending notification requests made by the application
    func removeAllPendingNotificationRequests() {
        notificationManager.removeAllPendingNotificationRequests()
    }
    
    private func nextTriggerDate(for request: UNNotificationRequest) -> Date? {
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            return trigger.nextTriggerDate()
        }
        
        if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
            return trigger.nextTriggerDate()
        }
        
        return nil
    }
}
