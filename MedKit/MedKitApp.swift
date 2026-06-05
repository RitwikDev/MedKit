//
//  MedKitApp.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import FirebaseCore
import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct MedKitApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            MedicineModel.self,
            CompositionModel.self,
            MedicineCustomFieldModel.self,
            CustomFieldModel.self,
            ScheduleModel.self,
            TagModel.self
        ])
    }
}
