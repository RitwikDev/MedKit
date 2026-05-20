//
//  ContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MedicinesListView()
                .tabItem {
                    Label("Medicines", systemImage: "pills")
                }
            
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
