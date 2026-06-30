//
//  MedicineCustomFieldStepperView.swift
//  MedKit
//
//  Created by Ritwik Dev on 14/06/26.
//

import SwiftUI
import DevKitUI

enum StepsEnum: Int {
    case chooseField = 1
    case addValues = 2
}

struct MedicineCustomFieldStepperView: View {
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @State private var step = StepsEnum.chooseField.rawValue
    @State private var selectedCustomField: CustomField = .init()
    @State private var customFieldValue: CustomFieldValue = .init()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(medicineEditorViewModel: MedicineEditorViewModel) {
        self.medicineEditorViewModel = medicineEditorViewModel
    }
    
    var body: some View {
        StepperView(
            currentStepIndex: $step,
            onNavigate: handleStepNavigated,
            onComplete: handleCompleted
        ) {
            AddCustomFieldsView(selectedCustomField: $selectedCustomField, medicineEditorViewModel: medicineEditorViewModel)
                .stepItem(index: StepsEnum.chooseField.rawValue, title: "Choose Field")
            
            MedicineCustomFieldFormView(
                medicineEditorViewModel: medicineEditorViewModel,
                customFieldDefinition: selectedCustomField,
                customFieldValue: $customFieldValue,
            )
            .stepItem(index: StepsEnum.addValues.rawValue, title: "Add Value")
        }
        .navigationTitle("Add Field")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedCustomField) { oldValue, newValue in
            step = StepsEnum.addValues.rawValue
        }
        .alert("Unable to proceed", isPresented: $showAlert) { } message: {
            Text(alertMessage)
        }
    }
    
    private func handleStepNavigated(from: Int) -> Bool {
        return selectedCustomField.isValid()
    }
    
    private func handleCompleted() {
        let (customFieldIsValid, invalidField) = customFieldValue.isValid()
        
        if !customFieldIsValid {
            showAlert = true
            alertMessage = invalidField.rawValue
            return
        }
        
        customFieldValue.definition = selectedCustomField
        medicineEditorViewModel.addCustomField(customFieldValue)
        
        if !(globalDataViewModel.allCustomFields.contains(selectedCustomField)){
            globalDataViewModel.allCustomFields.append(selectedCustomField)
        }
        
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MedicineCustomFieldStepperView(medicineEditorViewModel: .init())
            .environment(GlobalDataViewModel())
    }
}
