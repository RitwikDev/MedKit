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
    case ingredientForm(for: Ingredient)
    case medicineSchedule(for: Schedule)
    case addCustomFields
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .cameraAndImagePicker:
            CameraAndPhotoPickerView()
        case .medicineForm(let medicine):
            MedicineFormView(medicine: medicine)
        case .ingredientForm(let ingredient):
            IngredientEntryView(ingredient: ingredient)
        case .medicineSchedule(let schedule):
            ScheduleView(schedule: schedule)
        case .addCustomFields:
            MedicineCustomFieldStepperView()
        }
    }
}
