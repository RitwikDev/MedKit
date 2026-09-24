//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI
import UserNotifications

fileprivate enum DataType: String {
    case all = "All Data"
    case medicines = "All Medicines"
    case ingredients = "All Ingredients"
    case tags = "All Tags"
    case customFields = "All Custom Fields"
}

struct SettingsView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @State private var medicineListViewModel: MedicineViewModel = .init()
    @State private var enableNotifications: Bool = false
    @State private var isNotificationListViewPresented: Bool = false
    
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
                            SettingsResetApplicationView(medicineListViewModel: medicineListViewModel)
                        }
                    }
                    
                    Section("Version") {
                        Text(applicationVersion)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isNotificationListViewPresented.toggle()
                    } label: {
                        Label("Show Notifications", systemImage: "bell.badge.fill")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(isPresented: $isNotificationListViewPresented) {
                NotificationListView()
                    .interactiveDismissDisabled()
            }
            .navigationTitle("Settings")
            .onAppear {
                globalDataViewModel.fetchAllData()
            }
        }
    }
}

struct SettingsIngredientsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
            ForEach(globalDataViewModel.allIngredients) { ingredient in
                Text(ingredient.fullName)
            }
            .onDelete(perform: globalDataViewModel.deleteIngredient)
        }
        .navigationTitle("All Ingredients")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsTagsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
            ForEach(globalDataViewModel.allTags) { tag in
                Text(tag.value)
            }
            .onDelete(perform: globalDataViewModel.deleteTag)
        }
        .navigationTitle("All Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsCustomFieldsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
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
        .navigationTitle("All Custom Fields")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsResetApplicationView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    var medicineListViewModel: MedicineViewModel
    
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var dataType: DataType = .all

    var body: some View {
        Form {
            Button("Delete All Data", role: .destructive) {
                dataType = .all
                showDeleteConfirmationDialog.toggle()
            }
            .disabled(
                medicineListViewModel.medicines.isEmpty
                && globalDataViewModel.allIngredients.isEmpty
                && globalDataViewModel.allTags.isEmpty
                && globalDataViewModel.allCustomFields.isEmpty
            )
            
            Button("Delete All Medicines", role: .destructive) {
                dataType = .medicines
                showDeleteConfirmationDialog.toggle()
            }
            .disabled(medicineListViewModel.medicines.isEmpty)
            
            Button("Delete All Ingredients", role: .destructive) {
                dataType = .ingredients
                showDeleteConfirmationDialog.toggle()
            }
            .disabled(globalDataViewModel.allIngredients.isEmpty)
            
            Button("Delete All Tags", role: .destructive) {
                dataType = .tags
                showDeleteConfirmationDialog.toggle()
            }
            .disabled(globalDataViewModel.allTags.isEmpty)

            Button("Delete All Custom Fields", role: .destructive) {
                dataType = .customFields
                showDeleteConfirmationDialog.toggle()
            }
            .disabled(globalDataViewModel.allCustomFields.isEmpty)
        }
        .navigationTitle("Reset Application")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you sure?",
            isPresented: $showDeleteConfirmationDialog,
            titleVisibility: .visible) {
                Button("Delete \(dataType.rawValue)", role: .destructive) {
                    switch dataType {
                    case .all:
                        handleDeleteAllData()
                    case .medicines:
                        handleDeleteAllMedicines()
                    case .ingredients:
                        handleDeleteAllIngredients()
                    case .tags:
                        handleDeleteAllTags()
                    case .customFields:
                        handleDeleteAllCustomFields()
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
    }
    
    private func handleDeleteAllData() {
        withAnimation {
            globalDataViewModel.deleteAllTags()
            globalDataViewModel.deleteAllIngredients()
            globalDataViewModel.deleteAllCustomFields()
            medicineListViewModel.deleteAllMedicines()
        }
    }
    
    private func handleDeleteAllMedicines() {
        withAnimation {
            medicineListViewModel.deleteAllMedicines()
        }
    }
    
    private func handleDeleteAllIngredients() {
        withAnimation {
            globalDataViewModel.deleteAllIngredients()
        }
    }
    
    private func handleDeleteAllTags() {
        withAnimation {
            globalDataViewModel.deleteAllTags()
        }
    }
    
    private func handleDeleteAllCustomFields() {
        withAnimation {
            globalDataViewModel.deleteAllCustomFields()
        }
    }
}

#Preview {
    SettingsView()
        .environment(GlobalDataViewModel())
}
