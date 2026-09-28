//
//  MedKitApp.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import FirebaseCore
import FirebaseAppCheck
import SwiftData
import SwiftUI

@main
struct MedKitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var globalDataViewModel = GlobalDataViewModel()
    @State private var medicineViewModel = MedicineViewModel()
    @State private var router = NavigationRouter()
    @State private var notificationViewModel = NotificationViewModel(notificationManager: NotificationManager.shared)
    
    init() {
        NotificationManager.shared.registerCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(globalDataViewModel)
                .environment(medicineViewModel)
                .environment(router)
                .environment(notificationViewModel)
        }
    }
}
