//
//  AddCustomFieldsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 07/06/26.
//

import SwiftData
import SwiftUI

struct AddCustomFieldsView: View {
    @Binding var selectedCustomField: CustomField
    let medicineEditorViewModel: MedicineEditorViewModel

    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @State private var isSheetPresented = false
    @State private var searchText = ""
    
    init(selectedCustomField: Binding<CustomField>, medicineEditorViewModel: MedicineEditorViewModel) {
        self._selectedCustomField = selectedCustomField
        self.medicineEditorViewModel = medicineEditorViewModel
    }

    private var customFieldStructs: [CustomField] {
        globalDataViewModel.allCustomFields
    }
    
    var body: some View {
        VStack(spacing: 0) {
            availableCustomFields
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if #available(iOS 26.0, *) {
                    Button {
                        self.isSheetPresented = true
                    } label: {
                        Label("Create New", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent)
                } else {
                    Button {
                        self.isSheetPresented = true
                    } label: {
                        Label("Create New", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            CustomFieldDefinitionFormView(customField: $selectedCustomField)
        }
    }
    
    var availableCustomFields: some View {
        Form {
            Section {
                SearchBarView(searchText: self.$searchText)
            }
            
            FilteredCustomFieldsList(
                medicineEditorViewModel: medicineEditorViewModel,
                searchText: $searchText,
                selectedCustomField: $selectedCustomField,
            )
        }
    }
}

#Preview {
    NavigationStack {
        AddCustomFieldsView(selectedCustomField: .constant(.init()), medicineEditorViewModel: .init())
            .environment(GlobalDataViewModel())
    }
}
