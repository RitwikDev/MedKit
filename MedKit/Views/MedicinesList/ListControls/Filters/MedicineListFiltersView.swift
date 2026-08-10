//
//  MedicineListFiltersView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListFiltersView: View {
    @Binding var selectedTags: Set<UUID>
    @Binding var showOnlyExpiringSoon: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Filters")
                .font(.title3)
                .fontWeight(.bold)
            
            MedicineListFiltersTagsView(selectedTags: $selectedTags)
            MedicineListFiltersExpirationView(showOnlyExpiringSoon: $showOnlyExpiringSoon)
        }
    }
}

#Preview {
    MedicineListFiltersView(
        selectedTags: .constant([]),
        showOnlyExpiringSoon: .constant(false),
    )
}
