//
//  DatesSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct DatesSectionView: View {
    @Binding var manufacturedDate: Date?
    @Binding var expiryDate: Date?
    
    var body: some View {
        Section("Dates") {
            DatePickerView(label: "Manufacture Date", date: $manufacturedDate)
            DatePickerView(label: "Expiry Date", date: $expiryDate)
        }
    }
}

#Preview {
    DatesSectionView(manufacturedDate: .constant(.now), expiryDate: .constant(.now))
}
