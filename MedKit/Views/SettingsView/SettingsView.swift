//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var enableNotifications: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
