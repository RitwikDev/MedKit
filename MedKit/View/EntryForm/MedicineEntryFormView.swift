//
//  MedicineEntryFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import SwiftUI

private enum SheetType: String, Identifiable {
    case composition, customFields, tags
    var id: String { self.rawValue }
}

struct MedicineEntryFormView: View {
    @State var medicine: MedicineModel
    
    @State private var activeSheet: SheetType? = nil
    
    var body: some View {
        Form {
            Section("Name") {
                TextField(medicine.name.isEmpty ? "Name" : medicine.name, text: $medicine.name)
            }
            
            Section("Strength") {
                StrengthView(strength: $medicine.strength)
            }
            
            Section("Quantity") {
                Stepper(medicine.quantity.description, value: $medicine.quantity, in: 0...100)
            }
            
            Section("Dates") {
                DatePicker("Manufacture Date", selection: $medicine.manufacturedDate, displayedComponents: .date)
                DatePicker("Expiry Date", selection: $medicine.expiryDate, displayedComponents: .date)
            }
            
            Section(content: {
                if (medicine.compositions.isEmpty) {
                    EmptyView()
                } else {
                    CompositionView(composition: $medicine.compositions)
                }
            }, header: {
                SectionHeaderWithButtonView(sectionHeader: "Composition",
                                            buttonLabel: "New Composition",
                                            buttonSystemImage: "plus") {
                    activeSheet = .composition
                }
            })
            
            Section(content: {
                if (medicine.customFields.isEmpty) {
                    EmptyView()
                } else {
                    CustomFieldsView(customFields: $medicine.customFields)
                }
            }, header: {
                SectionHeaderWithButtonView(sectionHeader: "Custom Fields",
                                            buttonLabel: "New Custom Field",
                                            buttonSystemImage: "plus") {
                    activeSheet = .customFields
                }
            })
            
            Section(content: {
                if (medicine.tags.isEmpty) {
                    EmptyView()
                } else {
                    TagsView(tags: $medicine.tags)
                }
            }, header: {
                SectionHeaderWithButtonView(sectionHeader: "Tags",
                                            buttonLabel: "New Tag",
                                            buttonSystemImage: "plus") {
                    activeSheet = .tags
                }
            })
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .composition:
                CompositionEntrySheetView()
            case .customFields:
                CustomFieldEntrySheetView()
            case .tags:
                TagEntrySheetView()
            }
        }
        .toolbar {
            ToolbarItem {
                Button { } label: {
                    Label("Save", systemImage: "checkmark")
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicine.name.isEmpty ? "New Medicine" : medicine.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MedicineEntryFormView(medicine: sampleMedicines[7])
    }
}
