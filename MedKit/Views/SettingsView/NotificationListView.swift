//
//  NotificationListView.swift
//  MedKit
//
//  Created by Rishik Dev on 17/08/26.
//

import SwiftUI
import UserNotifications

struct NotificationListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GlobalDataViewModel.self) private var globalDataVM
    @Environment(NotificationViewModel.self) private var notificationVM
        
    var body: some View {
        NavigationStack {
            VStack {
                if (notificationVM.notificationRequests.isEmpty) {
                    EmptyEntryView(text: "No Notifications Have Been Scheduled")
                        .frame(maxHeight: .infinity)
                } else {
                    List(notificationVM.notificationRequests, id: \.identifier) { request in
                        VStack(alignment: .leading) {
                            if let medicineName = request.content.userInfo["medicineName"] as? String {
                                Text("Notification for \(medicineName)")
                                    .font(.headline)
                            }
                            
                            Group {
                                Text(request.content.title)
                                    
                                if (!request.content.body.isEmpty) {
                                    Text(request.content.body)
                                }
                            }
                            .font(.subheadline)
                            
                            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                               let nextDate = trigger.nextTriggerDate() {
                                VStack(alignment: .leading) {
                                    Text("Next: \(nextDate.formatted(date: .abbreviated, time: .shortened))")
                                    Text("Repeats: \(trigger.repeats ? "Yes" : "No")")
                                }
                                .font(.caption)
                            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
                                      let _ = trigger.nextTriggerDate() {
                                Text("Repeats in: \(Int(trigger.timeInterval))s")
                                    .font(.caption)
                            }
                            
                            Text(request.identifier)
                                .font(.caption)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                notificationVM.removePendingNotificationRequests(withIdentifiers: [request.identifier])
                            } label: {
                                Label("Unschedule Notification", systemImage: "bell.slash.fill")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                VStack(alignment: .leading) {
                    Text("Number of pending notifications: \(notificationVM.notificationRequests.count)")
                }
                .font(.subheadline)
                
                Button(role: .destructive) {
                    notificationVM.removeAllPendingNotificationRequests()
                    getPendingNotificationRequests()
                } label: {
                    Label("Unschedule All Notifications", systemImage: "bell.slash.fill")
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(notificationVM.notificationRequests.isEmpty)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationTitle("Scheduled Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                getPendingNotificationRequests()
            }
            .refreshable {
                getPendingNotificationRequests()
            }
        }
    }
    
    private func getPendingNotificationRequests() {
        Task {
            await notificationVM.getPendingNotificationRequests()
                
//            requests.append(getSampleNotificationRequest())
        }
    }
    
    private func getSampleNotificationRequest() -> UNNotificationRequest {
        let medicineIdentifier = UUID().uuidString
        let notificationIdentifier = UUID().uuidString
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Take Hajmola."
        content.body = "Please Take Your Medication."
        content.sound = .default
        content.userInfo = ["medicineId": medicineIdentifier, "medicineName": "Hajmola"]
        
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: .now)
        
        var triggerComponents = DateComponents()
        triggerComponents.hour = timeComponents.hour
        triggerComponents.minute = timeComponents.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        
        let sampleRequest = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        return sampleRequest
    }
}

#Preview {
    NotificationListView()
        .environment(GlobalDataViewModel())
        .environment(NotificationViewModel(notificationManager: NotificationManager.shared))
}
