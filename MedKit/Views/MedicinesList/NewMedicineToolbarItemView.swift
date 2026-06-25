//
//  NewMedicineToolbarItemView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct NewMedicineToolbarItemView: View {
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        Menu {
            Button {
                router.navigate(to: .medicineForm)
            } label: {
                Label("Manual", systemImage: "pencil")
            }
            
            Button {
                router.navigate(to: .cameraAndImagePicker)
            } label: {
                Label("Scan", systemImage: "camera.viewfinder")
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}

#Preview {
    NewMedicineToolbarItemView()
        .environment(MedicineEditorViewModel())
        .environment(NavigationRouter())
}
