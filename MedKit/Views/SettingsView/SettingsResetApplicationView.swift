//
//  SettingsResetApplicationView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import SwiftUI

private enum DataType: String {
    case all = "All Data"
    case medicines = "All Medicines"
    case ingredients = "All Ingredients"
    case tags = "All Tags"
    case customFields = "All Custom Fields"
}

struct SettingsResetApplicationView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Environment(MedicineViewModel.self) private var medicineListViewModel
    
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
                Button(role: .destructive) {
                    switch dataType {
                    case .all: handleDeleteAllData()
                    case .medicines: handleDeleteAllMedicines()
                    case .ingredients: handleDeleteAllIngredients()
                    case .tags: handleDeleteAllTags()
                    case .customFields: handleDeleteAllCustomFields()
                    }
                } label: {
                    Text("Erase \(Text(LocalizedStringKey(dataType.rawValue)))")
                }

            } message: {
                Text("You cannot undo this action.")
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
    SettingsResetApplicationView()
        .environment(GlobalDataViewModel())
        .environment(MedicineViewModel())
}
