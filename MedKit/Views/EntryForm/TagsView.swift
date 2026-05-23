//
//  TagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsView: View {
    @Binding var tags: [TagModel]
    @Binding var tagToEdit: TagModel
    let buttonAction: () -> Void
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        List {
            ForEach($tags) { $tag in
                HStack {
                    Button(tag.value) {
                        tagToEdit = tag
                        buttonAction()
                    }
                    .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    RoundedTintedButtonView(buttonAction: {
                        tagToEdit = tag
                        showDeleteConfirmation.toggle()
                    },
                                            title: "Delete \(tag.value)",
                                            systemImage: "xmark",
                                            tintColor: .red)
                }
            }
            
            Button("Add Tag") {
                tagToEdit = .init()
                buttonAction()
            }
        }
        .alert("Something went wrong",
               isPresented: $showError) {
            Button("Dismiss") { }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Delete \(tagToEdit.value)?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete") {
                withAnimation {
                    deleteTag()
                }
            }
        }
    }
    
    private func deleteTag() {
        var indexOfTagToDelete = -1
        
        for (index, tag) in self.tags.enumerated() {
            if (tag.id == tagToEdit.id) {
                indexOfTagToDelete = index
                break
            }
        }
        
        if (indexOfTagToDelete != -1) {
            tags.remove(at: indexOfTagToDelete)
        } else {
            errorMessage = "Could not delete \(tagToEdit)."
            showError = true
        }
    }
}

#Preview {
    TagsView(tags: .constant([.init(value:"Tag 1"), .init(value: "Tag 2")]),
             tagToEdit: .constant(.init()),
             buttonAction: { })
}
