//
//  MedKitApp.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftData
import SwiftUI

@main
struct MedKitApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var globalDataViewModel = GlobalDataViewModel()
    @State private var router = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(globalDataViewModel)
                .environment(router)
        }
    }
}
