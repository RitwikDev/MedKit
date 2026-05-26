//
//  TagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsSectionView: View {
    @Binding var tags: [Tag]
    let buttonAction: () -> Void
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var newTag: String = ""
    
    var body: some View {
        Section(
            content: {
                if (tags.isEmpty) {
                    EmptyEntryView(text: "No tags added")
                } else {
                    ForEach($tags) { $tag in
                        Text(tag.value)
                    }
                    .onDelete(perform: removeTags)
                }
            },
            header: {
                HStack {
                    Text("Tags")
                    Spacer()
                    RoundedTintedButtonView(title: "Manage",
                                            systemImage: "pencil",
                                            tintColor: .blue,
                                            buttonAction: buttonAction)
                }
            })
        .alert("Could not add tag", isPresented: $showError) {
            Button("Dismiss") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func addTag() {
        let lowercasedTags = tags.map { $0.value.lowercased() }
        if (lowercasedTags.contains(newTag.lowercasedTrimmed())) {
            errorMessage = "\(newTag.trimmed()) is already present"
            showError = true
            return
        }
        
        tags.append(.init(value: newTag.trimmed()))
        newTag = ""
    }
    
    private func removeTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }
}

#Preview {
    TagsSectionView(
        tags: .constant([.init(value:"Tag 1"), .init(value: "Tag 2")]),
        buttonAction: { },
    )
}
