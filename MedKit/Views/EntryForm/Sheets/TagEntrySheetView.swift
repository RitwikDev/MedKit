//
//  TagEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagEntrySheetView: View {
    private let tagsList = sampleTags
    @Binding var tags: [TagModel]
    @Binding var tagToEdit: TagModel
    
    @Environment(\.dismiss) private var dismiss
    @State private var draftTag: TagModel = .init()
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section(tagToEdit.value.isEmpty ? "New Composition" : "Edit Composition") {
                    TextField("Composition Name", text: $draftTag.value)
                }
                                
                Section("Previously Added Tags") {
                    ForEach(tagsList, id: \.self) { tagItem in
                        Button(tagItem.value) {
                            draftTag = tagItem.copy()
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            .onAppear {
                draftTag = tagToEdit.copy()
            }
            .alert("Something went wrong",
                   isPresented: $showError) {
                Button("Dismiss") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Label("Dismiss", systemImage: "xmark") }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if (tagToEdit.value.isEmpty) {
                            addTag()
                        } else {
                            replaceTag()
                        }
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .disabled(draftTag.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .interactiveDismissDisabled()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addTag() {
        draftTag.value = draftTag.value.trimmingCharacters(in: .whitespacesAndNewlines)
        tags.append(draftTag)
    }
    
    private func replaceTag() {
        var indexOfTagToReplace = -1
        
        for (index, tag) in self.tags.enumerated() {
            if (tag.id == tagToEdit.id) {
                indexOfTagToReplace = index
                break
            }
        }
        
        if (indexOfTagToReplace != -1) {
            draftTag.value = draftTag.value.trimmingCharacters(in: .whitespacesAndNewlines)
            tags[indexOfTagToReplace] = draftTag
        } else {
            errorMessage = "Could not replace \(tagToEdit.value)."
            showError = true
        }
    }

}

#Preview {
    TagEntrySheetView(tags: .constant([.init(value: "Tag 1"), .init(value: "Tag 2")]),
                      tagToEdit: .constant(.init()))
}
