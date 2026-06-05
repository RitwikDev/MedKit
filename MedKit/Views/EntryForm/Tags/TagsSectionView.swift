//
//  TagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsSectionView: View {
    @Environment(MedicineViewModel.self) private var medicineViewModel
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        Section("Tags") {
            ForEach(medicineViewModel.medicine.tags) { tag in
                Text(tag.value)
                    .foregroundStyle(.secondary)
            }
            .onDelete(perform: medicineViewModel.removeTags)
            
            Button("Manage Tags") {
                router.navigate(to: .manageMedicineTags)
            }
        }
    }
}

#Preview {
    Form {
        TagsSectionView()
    }
    .environment(MedicineViewModel())
    .environment(NavigationRouter())
}
