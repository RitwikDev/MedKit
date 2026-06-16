//
//  CustomFieldDefinitionFormView.swift
//  MedKit
//
//  Created by Ritwik Dev on 07/06/26.
//

import SwiftData
import SwiftUI

struct CustomFieldDefinitionFormView: View {
    @Query var customFields: [CustomFieldModel]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var customFieldRepository: CustomFieldWriteRepository?
    
    @Binding var customField: CustomField
    
    @State private var label: String = ""
    @State private var type: CustomFieldDataType = .text
    @State private var error: String? = nil
    
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
            .navigationTitle("Create Field")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if self.customFieldRepository == nil {
                    self.customFieldRepository = CustomFieldWriteRepository(modelContext: self.context)
                }
            }
        }
    }
    
    private func saveCustomField() -> Void {
        for customField in self.customFields {
            if customField.label.trimmedLocalisedEquals(self.label) {
                self.error = "Another field with the same label already exists"
                return
            }
        }
        
        do {
            guard let customFieldModel = try self.customFieldRepository?.save(
                field: CustomField(
                    label: self.label.trimmed,
                    dataType: self.type,
                )
            ) else {
                print("Failed to save custom field")
                return
            }
            
            self.customField = CustomField(
                persistentIdentifier: customFieldModel.id,
                label: customFieldModel.label,
                dataType: customFieldModel.dataType,
            )
        } catch {
            print("Failed to save custom field: \(error.localizedDescription)")
        }
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        CustomFieldDefinitionFormView(
            customField: .constant(.init())
        )
    }
}
