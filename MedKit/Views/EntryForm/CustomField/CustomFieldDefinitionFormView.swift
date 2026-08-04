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
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    @Binding var customField: CustomField
    
    @State private var label: String = ""
    @State private var type: CustomFieldDataType = .text
    
    private var customFieldExists: Bool {
        globalDataViewModel.allCustomFields.contains {
            $0.label.trimmedLocalizedCaseInsensitiveEquals(label)
        }
    }
    
    private var isDoneButtonDisabled: Bool {
        if (label.trimmedIsEmpty) { return true }
        return customFieldExists
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
                        if (customFieldExists) {
                            Text("Another field with the same label already exists")
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
            .scrollDismissesKeyboard(.interactively)
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
                    .disabled(isDoneButtonDisabled)
                }
            }
            .navigationTitle("New Field")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func saveCustomField() -> Void {
        guard !label.trimmedIsEmpty else { return }
        
        let newCustomField = CustomField(label: label.trimmed, dataType: type)
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
