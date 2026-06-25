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
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var step = StepsEnum.chooseField.rawValue
    @State private var selectedCustomField: CustomField = .init()
    @State private var customFieldValue: CustomFieldValue = .init()
    
    var body: some View {
        StepperView(
            currentStepIndex: $step,
            onNavigate: handleStepNavigated,
            onComplete: handleCompleted
        ) {
            AddCustomFieldsView(selectedCustomField: $selectedCustomField)
                .stepItem(index: StepsEnum.chooseField.rawValue, title: "Choose Field")
            
            MedicineCustomFieldFormView(
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
    }
    
    private func handleStepNavigated(from: Int) -> Bool {
        return selectedCustomField.isValid()
    }
    
    private func handleCompleted() -> Void {
        if !customFieldValue.isValid() {
            return
        }
        
        customFieldValue.definition = selectedCustomField
        medicineEditorViewModel.addCustomField(customFieldValue)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MedicineCustomFieldStepperView()
            .environment(GlobalDataViewModel())
            .environment(MedicineEditorViewModel())
    }
}
