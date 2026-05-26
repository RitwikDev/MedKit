//
//  ManageMedicineTagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftData
import SwiftUI

struct ManageMedicineTagsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var medicineTags: [Tag]
    @State var allTags: [Tag]
    
    @State private var filteredTags: [Tag] = []
    @State private var text: String = ""
    
    init(medicineTags: Binding<[Tag]>, allTags: [Tag]) {
        self._medicineTags = medicineTags
        let excluded = Set(medicineTags.wrappedValue)
        let initialFiltered = allTags.filter { !excluded.contains($0) }
        self._filteredTags = State(initialValue: initialFiltered)
        self._allTags = State(initialValue: allTags)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    currentTagsView
                    otherTagsView
                }
                .contentMargins(.bottom, 125)
                
                addTagView
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        medicineTags.forEach { print($0.value) }
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
            }
            .interactiveDismissDisabled()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var currentTagsView: some View {
        Section("Current Tags") {
            if (!medicineTags.isEmpty) {
                ForEach(medicineTags) { tag in
                    Text(tag.value)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                remove(tag: tag)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
            } else {
                EmptyEntryView(text: "No tags added")
            }
        }
    }
    
    private var otherTagsView: some View {
        Section("Other Tags") {
            if (!filteredTags.isEmpty) {
                ForEach(filteredTags) { tag in
                    Text(tag.value)
                        .swipeActions(edge: .trailing) {
                            Button {
                                add(tag: tag)
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                            .tint(.blue)
                        }
                }
            } else {
                EmptyEntryView(text: text.isEmpty ? "No other tags added" : "No results found")
            }
        }
    }
    
    private var addTagView: some View {
        HStack {
            TextField("Tag", text: $text)
                .task(id: text) {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    withAnimation {
                        filteredTags = filterTags()
                    }
                }
            
            RoundedTintedButtonView(title: "Add", systemImage: "plus", tintColor: .blue) {
                addNewCustomTag()
            }
            .disabled(disableAddButton())
        }
        .padding(15)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    private func add(tag: Tag) {
        withAnimation {
            medicineTags.append(tag)
            filteredTags.removeAll { $0.id == tag.id }
            filteredTags = filterTags()
        }
    }
    
    private func remove(tag: Tag) {
        withAnimation {
            medicineTags.removeAll { $0.id == tag.id }
            filteredTags.append(tag)
            filteredTags = filterTags()
        }
    }
    
    private func addNewCustomTag() {
        let cleanedText = text.trimmed()
        guard !cleanedText.isEmpty else { return }
        
        if let existingTag = allTags.first(where: { $0.value.localizedCaseInsensitiveCompare(cleanedText) == .orderedSame }) {
            if (!medicineTags.contains(existingTag)) {
                add(tag: existingTag)
            }
        } else {
            let newTag = Tag(value: cleanedText)
            allTags.append(newTag)
            add(tag: newTag)
        }
        text = ""
    }
    
    private func filterTags() -> [Tag] {
        let excludedTags = Set(medicineTags)
        
        if (text.trimmed().isEmpty) {
            return allTags.filter { !excludedTags.contains($0) }
        } else {
            return allTags.filter { tag in
                tag.value.localizedCaseInsensitiveContains(text.trimmed()) &&
                !excludedTags.contains(tag)
            }
        }
    }
    
    private func disableAddButton() -> Bool {
        let rawText = text.lowercasedTrimmed()
        
        let isTagPresent = medicineTags.contains { tag in
            tag.value.localizedCaseInsensitiveCompare(rawText) == .orderedSame
        }
        
        return rawText.isEmpty || isTagPresent
    }
}

#Preview {
    ManageMedicineTagsView(medicineTags: .constant([]), allTags: [])
}
