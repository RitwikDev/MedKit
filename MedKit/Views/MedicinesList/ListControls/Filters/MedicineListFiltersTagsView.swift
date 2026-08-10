//
//  MedicineListFiltersTagsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListFiltersTagsView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    @Binding var selectedTags: Set<UUID>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.headline)
            
            FlowLayout(spacing: 10, lineSpacing: 10) {
                ForEach(globalDataViewModel.allTags) { tag in
                    Button {
                        if (selectedTags.contains(tag.id)) {
                            selectedTags.remove(tag.id)
                        } else {
                            selectedTags.insert(tag.id)
                        }
                    } label: {
                        Text(tag.value)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTags.contains(tag.id) ? .blue : .clear)
                            .foregroundStyle(selectedTags.contains(tag.id) ? .white : .primary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color.blue,
                                        style: StrokeStyle(lineWidth: 2)
                                    )
                            }
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
            }
        }
        .padding()
        .roundedRectBackground(colour: Color(uiColor: .secondarySystemBackground))
    }
}

#Preview {
    MedicineListFiltersTagsView(
        selectedTags: .constant([]),
    )
    .environment(GlobalDataViewModel())
}
