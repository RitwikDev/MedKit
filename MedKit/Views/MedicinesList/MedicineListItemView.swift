//
//  MedicineListItemView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct MedicineListItemView: View {
    let medicine: Medicine
    
    var body: some View {
        NavigationLink(
            value: NavigationPathEnum.MedicineForm(for: medicine)
        ) {
            Text(medicine.name)
        }
    }
}

#Preview {
    MedicineListItemView(
        medicine: Medicine()
    )
}
