//
//  DatesSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct DatesSectionView: View {
    @Binding var medicine: MedicineModel
    
    var body: some View {
        Section("Dates") {
            DatePickerView(label: "Manufacture Date", date: $medicine.manufacturedDate)
            DatePickerView(label: "Expiry Date", date: $medicine.expiryDate)
        }
    }
}

#Preview {
    DatesSectionView(medicine: .constant(.init()))
}
