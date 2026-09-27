//
//  MedicineListFiltersExpirationView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListFiltersExpirationView: View {
    @Binding var showOnlyExpiringSoon: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Expiration")
                .font(.headline)
            
            Toggle("Show only medicines expiring soon", isOn: $showOnlyExpiringSoon)
        }
        .padding()
        .roundedRectBackground(colour: Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    MedicineListFiltersExpirationView(
        showOnlyExpiringSoon: .constant(false)
    )
}
