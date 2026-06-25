//
//  TagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsSectionView: View {
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        Section("Tags") {
            ForEach(medicineEditorViewModel.medicine.tags) { tag in
                Text(tag.value)
                    .foregroundStyle(.secondary)
            }
            .onDelete(perform: medicineEditorViewModel.removeTag)
            
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
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
