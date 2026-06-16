//
//  FilteredCustomFieldsList.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//


import SwiftUI
import SwiftData

struct FilteredCustomFieldsList: View {
    @Query var customFields: [CustomFieldModel]
    @Binding var selectedCustomField: CustomField
    
    init(
        searchText: String,
        selectedCustomField: Binding<CustomField>,
    ) {
        self._selectedCustomField = selectedCustomField
        
        let queryText = searchText 
        
        let predicate = #Predicate<CustomFieldModel> { field in
            queryText.isEmpty || field.label.localizedStandardContains(queryText)
        }
        
        self._customFields = Query(filter: predicate, sort: \.label)
    }
    
    private var customFieldStructs: [CustomField] {
        customFields.map { CustomField(from: $0) }
    }
    
    var body: some View {
        Section {
            if customFieldStructs.isEmpty {
                EmptyEntryView(text: "No Field Found")
            } else {
                ForEach(self.customFieldStructs) { customField in
                    Button {
                        selectedCustomField = customField
                    } label: {
                        HStack {
                            CustomFieldDefinitionListItem(customField: customField)
                            
                            Spacer()
                            
                            if selectedCustomField.persistentIdentifier == customField.persistentIdentifier {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
    }
}
