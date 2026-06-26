//
//  NavigationPathEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import Foundation
import SwiftUI

enum NavigationPathEnum: Hashable {
    case cameraAndImagePicker
    case medicineForm(for: Medicine)
    case ingredientForm(for: Ingredient, medicineEditorViewModel: MedicineEditorViewModel)
    case medicineSchedule(for: Schedule, medicineEditorViewModel: MedicineEditorViewModel)
    case addCustomFields(medicineEditorViewModel: MedicineEditorViewModel)
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .cameraAndImagePicker:
            CameraAndPhotoPickerView()
        case .medicineForm(let medicine):
            MedicineFormView(medicine: medicine)
        case .ingredientForm(let ingredient, let medicineEditorViewModel):
            IngredientEntryView(ingredient: ingredient, medicineEditorViewModel: medicineEditorViewModel)
        case .medicineSchedule(let schedule, let medicineEditorViewModel):
            ScheduleView(schedule: schedule, medicineEditorViewModel: medicineEditorViewModel)
        case .addCustomFields(let medicineEditorViewModel):
            MedicineCustomFieldStepperView(medicineEditorViewModel: medicineEditorViewModel)
        }
    }
}
