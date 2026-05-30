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
                router.navigate(to: .MedicineForm(for: .init()))
            } label: {
                Label("Manual", systemImage: "pencil")
            }
            
            Button {
                router.navigate(to: .MedicineForm(for: .init()))
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
}
