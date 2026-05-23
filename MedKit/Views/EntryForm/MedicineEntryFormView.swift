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
    
    @State private var draftMedicine: MedicineModel
    @State private var activeSheet: SheetType? = nil
    @State private var compositionToEdit: CompositionModel
    
    init(medicine: MedicineModel, compositionToEdit: CompositionModel = .init()) {
        self.medicine = medicine
        self.draftMedicine = medicine.copy()
        self.activeSheet = nil
        self.compositionToEdit = compositionToEdit
    }
    
    var body: some View {
        Form {
            // MARK: - Name
            Section("Name") {
                TextField("Name", text: $draftMedicine.name)
                    .autocorrectionDisabled()
            }
            
            // MARK: - Strength
            Section("Strength") {
                StrengthView(strength: $draftMedicine.strength)
            }
            
            // MARK: - Quantity
            Section("Quantity") {
                Stepper(draftMedicine.quantity.description, value: $draftMedicine.quantity, in: 0...100)
            }
            
            // MARK: - Dates
            Section("Dates") {
                DatePickerView(label: "Manufacture Date", date: $draftMedicine.manufacturedDate)
                DatePickerView(label: "Expiry Date", date: $draftMedicine.expiryDate)
            }

            // MARK: - Composition
            Section(content: {
                CompositionView(composition: $draftMedicine.composition,
                                compositionToEdit: $compositionToEdit) {
                    activeSheet = .composition
                }
            }, header: {
                Text("Composition")
            })

            // MARK: - Custom Fields
            Section(content: {
                CustomFieldsView(customFields: $draftMedicine.customFields) {
                    activeSheet = .customFields
                }
            }, header: {
                Text("Custom Fields")
            })

            // MARK: - Tags
            Section(content: {
                TagsView(tags: $draftMedicine.tags) {
                    activeSheet = .tags
                }
            }, header: {
                Text("Tags")
            })
            
            Button("Save") {
                print(draftMedicine.getJsonString())
            }
            
            Button("Cancel", role: .destructive) {
                print(medicine.getJsonString())
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .composition:
                CompositionEntrySheetView(composition: $draftMedicine.composition,
                                          compositionToEdit: $compositionToEdit)
            case .customFields:
                CustomFieldEntrySheetView()
            case .tags:
                TagEntrySheetView()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("\(medicine.name.isEmpty ? "New Medicine" : medicine.name)")
    }
}

#Preview {
    NavigationStack {
        MedicineEntryFormView(medicine: sampleMedicines[9],
                              compositionToEdit: .init())
    }
}
