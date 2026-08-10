//
//  MedicineListControlsSheetView.swift
//  MedKit
//
//  Created by Ritwik Dev on 09/08/26.
//

import SwiftUI

struct MedicineListControlsSheetView: View {
    @State var selectedTagsDraft: Set<UUID> = []
    @State var showOnlyExpiringSoonDraft: Bool = false
    @State var sortSelectionDraft: MedicineListSortOptionsEnum = .nameAscending
    
    @Binding var isPresented: Bool
    @Binding var selectedTags: Set<UUID>
    @Binding var showOnlyExpiringSoon: Bool
    @Binding var sortSelection: MedicineListSortOptionsEnum
    
    init(
        isPresented: Binding<Bool>,
        selectedTags: Binding<Set<UUID>>,
        showOnlyExpiringSoon: Binding<Bool>,
        sortSelection: Binding<MedicineListSortOptionsEnum>,
    ) {
        self._isPresented = isPresented
        self._selectedTags = selectedTags
        self._showOnlyExpiringSoon = showOnlyExpiringSoon
        self._sortSelection = sortSelection
        self._selectedTagsDraft = State(initialValue: selectedTags.wrappedValue)
        self._showOnlyExpiringSoonDraft = State(initialValue: showOnlyExpiringSoon.wrappedValue)
        self._sortSelectionDraft = State(initialValue: sortSelection.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    MedicineListFiltersView(
                        selectedTags: $selectedTagsDraft,
                        showOnlyExpiringSoon: $showOnlyExpiringSoonDraft,
                    )
                    
                    MedicineListSortControlsView(
                        selectedOption: $sortSelectionDraft,
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedTags = selectedTagsDraft
                        showOnlyExpiringSoon = showOnlyExpiringSoonDraft
                        sortSelection = sortSelectionDraft
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        MedicineListControlsSheetView(
            isPresented: .constant(true),
            selectedTags: .constant([]),
            showOnlyExpiringSoon: .constant(false),
            sortSelection: .constant(.nameAscending),
        )
    }
}
