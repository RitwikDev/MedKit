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
    
    private var medicineTags: Set<Tag> {
        Set(medicineEditorViewModel.medicine.tags)
    }
    
    private var filteredTags: [Tag] {
        return globalDataViewModel.allTags.filter { tag in
            if (medicineTags.contains(tag)) { return false }
            if newTagValue.trimmedIsEmpty { return true }
            return tag.value.localizedStandardContains(newTagValue)
        }
    }
    
    private var showNewTagButton: Bool {
        !newTagValue.trimmedIsEmpty
        && !globalDataViewModel.allTags.contains {
            $0.value.trimmedLocalizedCaseInsensitiveEquals(newTagValue)
        }
        && !medicineTags.contains {
            $0.value.trimmedLocalizedCaseInsensitiveEquals(newTagValue)
        }
    }
    
    var body: some View {
        Section("Tags") {
            newTagInputView
            
//            if (showSuggestions) {
//                tagHorizontalScrollView
//            }
            
            medicineTagsListView
        }
        .onChange(of: isTagTextFieldFocussed) { _, isFocused in
            withAnimation(.spring) {
                showSuggestions = isFocused && (!filteredTags.isEmpty || showNewTagButton)
            }
        }
        .onChange(of: !filteredTags.isEmpty || showNewTagButton) { _, show in
            withAnimation {
                showSuggestions = show
            }
        }
    }
    
    private var newTagInputView: some View {
        HStack {
            TextField("Add tag", text: $newTagValue)
                .focused($isTagTextFieldFocussed)
                .toolbar {
                    if(showSuggestions) {
                        ToolbarItem(placement: .keyboard) {
                            tagHorizontalScrollView
                        }
                    }
                }
        }
    }
    
    private var medicineTagsListView: some View {
        ForEach(medicineEditorViewModel.medicine.tags) { tag in
            Text(tag.value)
        }
        .onDelete(perform: handleOnDelete)
    }
    
    private var tagHorizontalScrollView: some View {
        let search = newTagValue.trimmed
        
        return ScrollView(.horizontal) {
            HStack {
                if (showNewTagButton) {
                    Button(search, action: handleAddNewTag)
                }
                
                ForEach(filteredTags) { tag in
                    Button(tag.value) { handleAddExistingTag(tag) }
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .transition(.scale.combined(with: .opacity))
            .animation(.snappy, value: filteredTags)
            .animation(.snappy, value: showNewTagButton)
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
