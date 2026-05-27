//
//  ManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftData
import SwiftUI

struct ManageMedicineTagsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @State var currentTags: [Tag]
    @State var allTags: [Tag]
    let onSave: ([Tag]) -> Void
    
    @State private var filteredTags: [Tag] = []
    @State private var text: String = ""
    
    private var dynamicHeight: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge:
            return 125
        case .accessibility1:
            return 150
        case .accessibility2, .accessibility3:
            return 175
        case .accessibility4, .accessibility5:
            return 200
        @unknown default:
            return 125
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    currentTagsView
                    otherTagsView
                }
                
                Form {
                    Section("New Tag") {
                        addTagView
                    }
                }
                .frame(maxHeight: dynamicHeight)
                .scrollDisabled(true)
            }
            .onAppear {
                let excluded = Set(currentTags.map { $0.value.lowercasedTrimmed() })
                let initialFiltered = allTags.filter { !excluded.contains($0.value.lowercasedTrimmed()) }
                self.filteredTags = initialFiltered
            }
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button("Done") {
                        onSave(currentTags)
                        dismiss()
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
            if (!currentTags.isEmpty) {
                ForEach(currentTags) { tag in
                    Text(tag.value)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                remove(tag: tag)
                            } label: {
                                Label("Remove", systemImage: "minus")
                                    .labelStyle(.iconOnly)
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
                                    .labelStyle(.iconOnly)
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
    }
    
    private func add(tag: Tag) {
        withAnimation {
            currentTags.append(tag)
            filteredTags.removeAll { $0.id == tag.id }
            filteredTags = filterTags()
        }
    }
    
    private func remove(tag: Tag) {
        withAnimation {
            currentTags.removeAll { $0.id == tag.id }
            filteredTags.append(tag)
            filteredTags = filterTags()
        }
    }
    
    private func addNewCustomTag() {
        let cleanedText = text.trimmed()
        guard !cleanedText.isEmpty else { return }
        
        if let existingTag = allTags.first(where: { $0.value.localizedCaseInsensitiveCompare(cleanedText) == .orderedSame }) {
            if (!currentTags.contains(existingTag)) {
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
        let excludedTags = Set(currentTags.map { $0.value.lowercasedTrimmed() })
        
        if (text.trimmed().isEmpty) {
            return allTags.filter { !excludedTags.contains($0.value.lowercasedTrimmed()) }
        } else {
            return allTags.filter { tag in
                tag.value.localizedCaseInsensitiveContains(text.trimmed()) &&
                !excludedTags.contains(tag.value.lowercasedTrimmed())
            }
        }
    }
    
    private func disableAddButton() -> Bool {
        let rawText = text.lowercasedTrimmed()
        
        let isTagPresent = currentTags.contains { tag in
            tag.value.localizedCaseInsensitiveCompare(rawText) == .orderedSame
        }
        
        return rawText.isEmpty || isTagPresent
    }
}

#Preview {
    ManageMedicineTagsSheetView(
        currentTags: [],
        allTags: [],
        onSave: { _ in }
    )
}
