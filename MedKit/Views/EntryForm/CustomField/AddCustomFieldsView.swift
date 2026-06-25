//
//  AddCustomFieldsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 07/06/26.
//

import SwiftData
import SwiftUI

struct AddCustomFieldsView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    
    @Binding var selectedCustomField: CustomField
    
    @State private var isSheetPresented = false
    @State private var searchText = ""

    private var customFieldStructs: [CustomField] {
        globalDataViewModel.allCustomFields
    }
    
    var body: some View {
        VStack(spacing: 0) {
            availableCustomFields
        }
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
                searchText: searchText,
                selectedCustomField: $selectedCustomField,
            )
        }
        .listSectionSpacing(8)
        .contentMargins(.top, 8)
    }
}

#Preview {
    NavigationStack {
        AddCustomFieldsView(selectedCustomField: .constant(.init()))
            .environment(GlobalDataViewModel())
            .environment(MedicineEditorViewModel())
    }
}
