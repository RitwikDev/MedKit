//
//  SettingsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftData
import SwiftUI
import UserNotifications

private enum DataType: String {
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
    @State private var showDeleteConfirmationDialog: Bool = false
    @State private var dataType: DataType = .all
    @State private var isNotificationListViewPresented: Bool = false
    
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
