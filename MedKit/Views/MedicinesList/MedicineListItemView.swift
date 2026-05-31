//
//  MedicineListItemView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct MedicineListItemView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    let medicine: Medicine
    
    var body: some View {
        Button {
            medicineViewModel.medicine = medicine
            router.navigate(to: .medicineForm)
        } label: {
            Text(medicine.name)
        }
    }
}

#Preview {
    MedicineListItemView(
        medicine: Medicine(name: "Medicine Name", quantity: 10)
    )
}
