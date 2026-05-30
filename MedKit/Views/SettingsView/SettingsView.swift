//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Query private var tags: [TagModel]
    @Query private var compositions: [CompositionModel]
    @Environment(\.modelContext) private var modelContext
    @State private var enableNotifications: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                    }
                    
                    Section("Compositions") {
                        if (compositions.isEmpty) {
                            EmptyEntryView(text: "No Compositions Added")
                        } else {
                            ForEach(compositions) { composition in
                                Text(composition.fullName)
                            }
                        }
                    }
                    
                    Section("Tags") {
                        if (tags.isEmpty) {
                            EmptyEntryView(text: "No Tags Added")
                        } else {
                            ForEach(tags) { tag in
                                Text(tag.value)
                            }
                        }
                    }
                    
                    Section("Reset Application") {
                        Button("Delete All Data", role: .destructive) {
                            deleteAllData(from: modelContext)
                        }
                        
                        Button("Delete All Medicines", role: .destructive) {
                            deleteAllData(from: modelContext, of: .medicines)
                        }
                        
                        Button("Delete All Compositions", role: .destructive) {
                            deleteAllData(from: modelContext, of: .compositions)
                        }

                        Button("Delete All Tags", role: .destructive) {
                            deleteAllData(from: modelContext, of: .tags)
                        }
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
