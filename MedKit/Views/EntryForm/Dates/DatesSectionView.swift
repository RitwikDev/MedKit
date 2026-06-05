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
            DatePickerView(label: "\(manufacturedDate == nil ? "Add Manufacture Date" : "Manufacture Date")", date: $manufacturedDate)
            DatePickerView(label: "\(manufacturedDate == nil ? "Add Expiry Date" : "Expiry Date")", date: $expiryDate)
        }
    }
}

#Preview {
    Form {
        DatesSectionView(manufacturedDate: .constant(.now), expiryDate: .constant(.now))
    }
}
