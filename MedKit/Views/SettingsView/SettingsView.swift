//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var applicationVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Ingredients") {
                        if (globalDataViewModel.allIngredients.isEmpty) {
                            EmptyEntryView(text: "No Ingredients Added")
                        } else {
                            NavigationLink("All Ingredients") {
                                SettingsIngredientsListView()
                            }
                        }
                    }
                    
                    Section("Tags") {
                        if (globalDataViewModel.allTags.isEmpty) {
                            EmptyEntryView(text: "No Tags Added")
                        } else {
                            NavigationLink("All Tags") {
                                SettingsTagsListView()
                            }
                        }
                    }
                    
                    Section("Custom Fields") {
                        if (globalDataViewModel.allCustomFields.isEmpty) {
                            EmptyEntryView(text: "No Custom Fields Added")
                        } else {
                            NavigationLink("All Custom Fields") {
                                SettingsCustomFieldsListView()
                            }
                        }
                    }
                    
                    Section("Reset Application") {
                        NavigationLink("Reset Application") {
                            SettingsResetApplicationView()
                        }
                    }
                    
                    Section("Version") {
                        Text(applicationVersion)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                globalDataViewModel.fetchAllData()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(GlobalDataViewModel())
}
