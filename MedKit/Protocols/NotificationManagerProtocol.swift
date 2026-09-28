//
//  NotificationManagerProtocol.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import Foundation
import UserNotifications

protocol NotificationManagerProtocol {
    func requestAuthorisation()
    func registerCategories()
    func scheduleInitialNotification(for medicine: Medicine) throws
    func getPendingNotificationRequests() async -> [UNNotificationRequest]
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removePendingNotificationRequests(for medicineId: UUID) async
    func removeAllPendingNotificationRequests()
}
