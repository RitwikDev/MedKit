//
//  CustomFieldDefinitionFormView.swift
//  MedKit
//
//  Created by Ritwik Dev on 07/06/26.
//

import SwiftData
import SwiftUI

struct CustomFieldDefinitionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    @Binding var customField: CustomField
    
    @State private var label: String = ""
    @State private var type: CustomFieldDataType = .text
    @State private var error: String? = nil
    
    private var customFields: [CustomField] {
        globalDataViewModel.allCustomFields
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(
                    content: {
                        TextField("Label", text: $label)
                    }, header: {
                        Text("Label")
                    }, footer: {
                        if let error = self.error {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                )
                
                Picker("Type", selection: $type) {
                    ForEach(CustomFieldDataType.allCases) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.inline)
                .tint(.secondary)
            }
            .onChange(of: self.label, { oldValue, newValue in
                self.error = nil
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveCustomField()
                    }
                    .disabled(self.label.trimmedIsEmpty)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Create Field")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveCustomField() -> Void {
        for customField in self.customFields {
            if customField.label.trimmedLocalizedCaseInsensitiveEquals(self.label) {
                self.error = "Another field with the same label already exists"
                return
            }
        }
        
        let newCustomField = CustomField(label: label.trimmed, dataType: type)
        globalDataViewModel.allCustomFields.append(newCustomField)
        customField = newCustomField
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CustomFieldDefinitionFormView(
            customField: .constant(.init())
        )
        .environment(GlobalDataViewModel())
    }
}
