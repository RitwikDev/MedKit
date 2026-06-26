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
    let medicineEditorViewModel: MedicineEditorViewModel
    @Binding var searchText: String
    @Binding var selectedCustomField: CustomField
    
    private let medicineCustomFields: Set<CustomField?>
    
    init(
        medicineEditorViewModel: MedicineEditorViewModel,
        searchText: Binding<String>,
        selectedCustomField: Binding<CustomField>,
    ) {
        self.medicineEditorViewModel = medicineEditorViewModel
        self._searchText = searchText
        self._selectedCustomField = selectedCustomField
        self.medicineCustomFields = Set(medicineEditorViewModel.medicine.customFields.map { $0.definition })
    }
        
    private var filteredCustomFields: [CustomField] {
        /// Uncomment the two lines below to hide the custom fields from the list which are already
        /// present in the medicine.
        /// Currently, all custom fields are visible—even the ones already present in the medicine—as
        /// certain fields, such as 'Prescription' might be reused by users.
//        let medicineCustomFields = Set(medicineEditorViewModel.medicine.customFields.map { $0.definition })
        
        return globalDataViewModel.allCustomFields.filter { customField in
//            if (medicineCustomFields.contains(customField)) { return false }
            if (searchText.trimmedIsEmpty) { return true }
            return customField.label.localizedStandardContains(searchText)
        }
    }
    
    var body: some View {
        Section {
            if filteredCustomFields.isEmpty {
                EmptyEntryView(text: "No Field Found")
            } else {
                ForEach(filteredCustomFields) { customField in
                    Button {
                        selectedCustomField = customField
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                CustomFieldDefinitionListItem(customField: customField)
                                
                                if (medicineCustomFields.contains(customField)) {
                                    Text("Already present in \(medicineEditorViewModel.medicine.name)")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                        .italic()
                                }
                            }
                            
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
    }
}

#Preview {
    Form {
        FilteredCustomFieldsList(
            medicineEditorViewModel: .init(),
            searchText: .constant(""),
            selectedCustomField: .constant(.init())
        )
    }
    .environment(GlobalDataViewModel())
}
