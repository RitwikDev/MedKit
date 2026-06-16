//
//  ContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var router = NavigationRouter()
    
    var body: some View {
        TabView {
            MedicineListView()
                .tabItem {
                    Label("Medicines", systemImage: "pills")
                }
            
            CalendarView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .environment(router)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
