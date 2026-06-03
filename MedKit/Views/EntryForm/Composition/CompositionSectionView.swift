//
//  CompositionSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionSectionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    var body: some View {
        Section("Composition") {
            ForEach(medicineViewModel.medicine.composition) { composition in
                Button(composition.fullName) {
                    router.navigate(to: .editComposition(for: composition))
                }
                .foregroundStyle(.primary)
            }
            .onDelete(perform: medicineViewModel.removeComposition)
            
            Button("Add Composition") {
                router.navigate(to: .addComposition)
            }
        }
    }
}

#Preview {
    Form {
        CompositionSectionView()
    }
    .environment(NavigationRouter())
    .environment(MedicineViewModel())
}
