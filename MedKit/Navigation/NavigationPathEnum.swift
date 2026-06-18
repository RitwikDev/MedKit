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
    case medicineForm
    case addIngredient
    case editIngredient(for: Ingredient)
    case medicineSchedule(for: Schedule)
    case manageMedicineTags
    case addCustomFields
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .cameraAndImagePicker:
            CameraAndPhotoPickerView()
        case .medicineForm:
            MedicineFormView()
        case .addIngredient:
            AddIngredientView()
        case .editIngredient(let ingredient):
            EditIngredientView(ingredient: ingredient)
        case .medicineSchedule(let schedule):
            ScheduleView(schedule: schedule)
        case .manageMedicineTags:
            ManageMedicineTagsView()
        case .addCustomFields:
            MedicineCustomFieldStepperView()
        }
    }
}
