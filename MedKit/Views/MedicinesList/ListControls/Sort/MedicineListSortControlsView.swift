//
//  MedicineListSortControlsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListSortControlsView: View {
    @Binding var selectedOption: MedicineListSortOptionsEnum
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sort")
                .font(.title3)
                .fontWeight(.bold)
            
            Picker("Select", selection: $selectedOption) {
                ForEach(MedicineListSortOptionsEnum.allCases) { option in
                    Text(option.rawValue).tag(option.rawValue)
                }
            }
            .pickerStyle(.wheel)
            .roundedRectBackground(colour: Color(uiColor: .secondarySystemBackground))
        }
    }
}

#Preview {
    MedicineListSortControlsView(
        selectedOption: .constant(.nameAscending),
    )
}
