//
//  TagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsSectionView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    
    @FocusState private var isTagTextFieldFocussed: Bool
    @State private var newTagValue: String = ""
    
    // A proxy state to force the Form to animate
    // FocusState does not animate views
    @State private var showSuggestions: Bool = false
    
    private var filteredTags: [Tag] {
        let medicineTags = Set(medicineEditorViewModel.medicine.tags)
        
        return globalDataViewModel.allTags.filter { tag in
            if (medicineTags.contains(tag)) { return false }
            if newTagValue.trimmedIsEmpty { return true }
            return tag.value.localizedStandardContains(newTagValue)
        }
    }
    
    private var isAddButtonDisabled: Bool {
        if (newTagValue.trimmedIsEmpty) { return true }
        return globalDataViewModel.allTags.contains {
            $0.value.trimmedLocalizedCaseInsensitiveEquals(newTagValue)
        }
    }
    
    var body: some View {
        Section("Tags") {
            newTagInputView
            
            if (showSuggestions) {
                tagHorizontalScrollView
            }
            
            medicineTagsListView
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: isTagTextFieldFocussed) { _, isFocused in
            withAnimation(.spring) {
                showSuggestions = isFocused
            }
        }
        .onChange(of: filteredTags.isEmpty) { _, filteredTagsIsEmpty in
            withAnimation {
                showSuggestions = !filteredTagsIsEmpty
            }
        }
    }
    
    private var newTagInputView: some View {
        HStack {
            TextField("Tag", text: $newTagValue)
                .focused($isTagTextFieldFocussed)
            
            CircularButtonView(buttonAction: handleAddNewTag)
                .disabled(isAddButtonDisabled)
        }
    }
    
    private var medicineTagsListView: some View {
        ForEach(medicineEditorViewModel.medicine.tags) { tag in
            Text(tag.value)
                .foregroundStyle(.secondary)
        }
        .onDelete(perform: handleOnDelete)
    }
    
    private var tagHorizontalScrollView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(filteredTags) { tag in
                    Button(tag.value) { handleAddExistingTag(tag) }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.snappy, value: filteredTags)
        }
        .scrollIndicators(.hidden)
    }
    
    private func handleAddNewTag() {
        guard !newTagValue.trimmedIsEmpty else { return }
        let tag = Tag(value: newTagValue)
        
        withAnimation {
            medicineEditorViewModel.addTag(tag)
            globalDataViewModel.allTags.append(tag)
            newTagValue = ""
        }
    }
    
    private func handleAddExistingTag(_ tag: Tag) {
        withAnimation {
            medicineEditorViewModel.addTag(tag)
            newTagValue = ""
        }
    }
    
    public func handleOnDelete(indexSet: IndexSet) {
        withAnimation {
            medicineEditorViewModel.removeTag(at: indexSet)
        }
    }
}

#Preview {
    Form {
        TagsSectionView()
    }
    .environment(GlobalDataViewModel())
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
