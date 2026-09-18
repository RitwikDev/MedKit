//
//  MedicineListControlsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListControlsView: View {
    @Binding var isDrawerOpen: Bool
    
    var body: some View {
        Button {
            withAnimation(.snappy) {
                isDrawerOpen.toggle()
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}

#Preview {
    MedicineListControlsView(
        isDrawerOpen: .constant(false),
    )
}
