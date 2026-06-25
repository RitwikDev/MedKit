//
//  FilteredCustomFieldsList.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//


import SwiftUI
import SwiftData

struct FilteredCustomFieldsList: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Binding var selectedCustomField: CustomField
    @State private var customFields: [CustomField] = []
    
    init(
        searchText: String,
        selectedCustomField: Binding<CustomField>,
    ) {
        self._selectedCustomField = selectedCustomField
        /*
        let queryText = searchText
        
        let predicate = #Predicate<CustomFieldModel> { field in
            queryText.isEmpty || field.label.localizedStandardContains(queryText)
        }
        
        self._customFields = Query(filter: predicate, sort: \.label)
         */
    }
    
    var body: some View {
        Section {
            if customFields.isEmpty {
                EmptyEntryView(text: "No Field Found")
            } else {
                ForEach(customFields) { customField in
                    Button {
                        selectedCustomField = customField
                    } label: {
                        HStack {
                            CustomFieldDefinitionListItem(customField: customField)
                            
                            Spacer()
                            
                            if selectedCustomField == customField {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .onAppear {
            customFields = globalDataViewModel.allCustomFields
        }
    }
}

#Preview {
    Form {
        FilteredCustomFieldsList(
            searchText: "",
            selectedCustomField: .constant(.init())
        )
    }
    .environment(GlobalDataViewModel())
}
