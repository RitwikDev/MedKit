//
//  ManageMedicineTagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftUI

struct ManageMedicineTagsView: View {
    @Binding var medicineTags: [TagModel]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var filteredTags: [TagModel] = []
    @State private var allTags = sampleTags
    @State private var text: String = ""
    
    init(medicineTags: Binding<[TagModel]>) {
        self._medicineTags = medicineTags
        let excluded = Set(medicineTags.wrappedValue)
        let initialFiltered = sampleTags.filter { !excluded.contains($0) }
        self._filteredTags = State(initialValue: initialFiltered)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section("Current Tags") {
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
                    }
                    
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
                            Text(text.isEmpty ? "No other tags available" : "No results found")
                                .foregroundStyle(.secondary)
                                .italic()
                        }
                    }
                }
                .contentMargins(.bottom, 125)
                
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
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
                .background(.ultraThinMaterial)
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
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func add(tag: TagModel) {
        withAnimation {
            medicineTags.append(tag)
            filteredTags.removeAll { $0.id == tag.id }
            filteredTags = filterTags()
        }
    }
    
    private func remove(tag: TagModel) {
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
            let newTag = TagModel(value: cleanedText)
            allTags.append(newTag)
            add(tag: newTag)
        }
        text = ""
    }
    
    private func filterTags() -> [TagModel] {
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
    ManageMedicineTagsView(medicineTags: .constant(sampleMedicines[8].tags))
}
