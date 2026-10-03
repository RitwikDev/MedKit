//
//  NavigationPathEnum.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import Foundation
import SwiftUI

enum NavigationPathEnum: Hashable {
    case cameraAndPhotoPicker
    case medicineForm(for: Medicine, isEditable: Bool = true)
    case ingredientForm(for: Ingredient, medicineEditorViewModel: MedicineEditorViewModel)
    case medicineDosage(for: DosageModel, medicineEditorViewModel: MedicineEditorViewModel)
    case addCustomFields(medicineEditorViewModel: MedicineEditorViewModel)
    case documentPreview(document: Document)
    case zoomablePhotoView(image: UIImage)
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .cameraAndPhotoPicker:
            CameraAndPhotoPickerView()
        case .medicineForm(let medicine, let isEditable):
            MedicineFormView(medicine: medicine, isEditable: isEditable)
                .keyboardToolbar()
        case .ingredientForm(let ingredient, let medicineEditorViewModel):
            IngredientEntryView(ingredient: ingredient, medicineEditorViewModel: medicineEditorViewModel)
                .keyboardToolbar()
        case .medicineDosage(let dosage, let medicineEditorViewModel):
            DosageView(dosage: dosage, medicineEditorViewModel: medicineEditorViewModel)
                .keyboardToolbar()
        case .addCustomFields(let medicineEditorViewModel):
            MedicineCustomFieldStepperView(medicineEditorViewModel: medicineEditorViewModel)
                .keyboardToolbar()
        case .documentPreview(let document):
            DocumentPreviewView(document: document)
                .ignoresSafeArea()
        case .zoomablePhotoView(let photo):
            ZoomablePhotoView(photo: photo)
                .ignoresSafeArea()
        }
    }
}
