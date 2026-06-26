//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @State private var medicineListViewModel: MedicineListViewModel = .init()
    @State private var enableNotifications: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                    }
                    
                    Section("Ingredients") {
                        if (globalDataViewModel.allIngredients.isEmpty) {
                            EmptyEntryView(text: "No Ingredients Added")
                        } else {
                            ForEach(globalDataViewModel.allIngredients) { ingredient in
                                Text(ingredient.fullName)
                            }
                            .onDelete(perform: globalDataViewModel.deleteIngredient)
                        }
                    }
                    
                    Section("Tags") {
                        if (globalDataViewModel.allTags.isEmpty) {
                            EmptyEntryView(text: "No Tags Added")
                        } else {
                            ForEach(globalDataViewModel.allTags) { tag in
                                Text(tag.value)
                            }
                            .onDelete(perform: globalDataViewModel.deleteTag)
                        }
                    }
                    
                    Section("Custom Fields") {
                        if (globalDataViewModel.allCustomFields.isEmpty) {
                            EmptyEntryView(text: "No Custom Fields Added")
                        } else {
                            ForEach(globalDataViewModel.allCustomFields) { customField in
                                VStack(alignment: .leading) {
                                    Text(customField.label)
                                    Text(customField.dataType.rawValue)
                                        .foregroundStyle(.secondary)
                                        .font(.callout)
                                }
                            }
                            .onDelete(perform: globalDataViewModel.deleteCustomField)
                        }
                    }
                    
                    Section("Reset Application") {
                        Button("Delete All Data", role: .destructive) {
                            globalDataViewModel.deleteAllTags()
                            globalDataViewModel.deleteAllIngredients()
                            globalDataViewModel.deleteAllCustomFields()
                            medicineListViewModel.deleteAllMedicines()
                        }
                        
                        Button("Delete All Medicines", role: .destructive) {
                            medicineListViewModel.deleteAllMedicines()
                        }
                        
                        Button("Delete All Tags", role: .destructive) {
                            globalDataViewModel.deleteAllTags()
                        }
                        
                        Button("Delete All Ingredients", role: .destructive) {
                            globalDataViewModel.deleteAllIngredients()
                        }

                        Button("Delete All Custom Fields", role: .destructive) {
                            globalDataViewModel.deleteAllCustomFields()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                globalDataViewModel.fetchAllCustomFields()
                globalDataViewModel.fetchAllIngredients()
                globalDataViewModel.fetchAllTags()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(GlobalDataViewModel())
}
