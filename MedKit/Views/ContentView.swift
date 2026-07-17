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
            MedicineListView()
                .tabItem {
                    Label("Medicines", systemImage: "pills")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
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
        .environment(GlobalDataViewModel())
        .environment(MedicineEditorViewModel())
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
}
