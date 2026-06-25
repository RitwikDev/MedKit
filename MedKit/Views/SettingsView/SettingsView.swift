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
    @Environment(MedicineListViewModel.self) private var medicineListViewModel
    @State private var enableNotifications: Bool = false
    @State private var customFields: [CustomField] = []
    @State private var ingredients: [Ingredient] = []
    @State private var tags: [Tag] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: $enableNotifications)
                    }
                    
                    Section("Ingredients") {
                        if (ingredients.isEmpty) {
                            EmptyEntryView(text: "No Ingredients Added")
                        } else {
                            ForEach(ingredients) { ingredient in
                                Text(ingredient.fullName)
                            }
                            .onDelete(perform: globalDataViewModel.deleteIngredient)
                        }
                    }
                    
                    Section("Tags") {
                        if (tags.isEmpty) {
                            EmptyEntryView(text: "No Tags Added")
                        } else {
                            ForEach(tags) { tag in
                                Text(tag.value)
                            }
                            .onDelete(perform: globalDataViewModel.deleteTag)
                        }
                    }
                    
                    Section("Custom Fields") {
                        if (customFields.isEmpty) {
                            EmptyEntryView(text: "No Custom Fields Added")
                        } else {
                            ForEach(customFields) { customField in
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
                
                customFields = globalDataViewModel.allCustomFields
                ingredients = globalDataViewModel.allIngredients
                tags = globalDataViewModel.allTags
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(GlobalDataViewModel())
        .environment(MedicineListViewModel())
}
