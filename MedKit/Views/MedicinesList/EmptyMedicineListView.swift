//
//  EmptyMedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct EmptyMedicineListView: View {
    var body: some View {
        EmptyEntryView(text: "No Medicines Added")
            .foregroundStyle(.secondary)
            .font(.title3)
            .fontWeight(.black)
    }
}

#Preview {
    EmptyMedicineListView()
}
