//
//  TagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsView: View {
    @Binding var tags: [String]
    let buttonAction: () -> Void
    
    @State private var showAlert: Bool = false
    @State private var showError: Bool = false
    @State private var tappedTag: String = ""
    @State private var renamedTappedTag: String = ""
    @State private var errorMessage: String = ""
    @State private var indexOfTappedTag: Int = -1
    
    var body: some View {
        List {
            ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                Button(tag) {
                    tappedTag = tag
                    renamedTappedTag = tag
                    indexOfTappedTag = index
                    showAlert.toggle()
                }
                .foregroundStyle(.primary)
            }
            
            Button("Add Tag") { buttonAction() }
        }
        .alert("Rename \(tappedTag)", isPresented: $showAlert) {
            TextField(tappedTag, text: $renamedTappedTag)
            Button("Dismiss", action: clearVariables)
            Button("Done", action: renameTag)
            .disabled(renamedTappedTag == tappedTag || renamedTappedTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .alert("Could not rename \(tappedTag)", isPresented: $showError) {
            Button("Dismiss", action: clearVariables)
        } message: {
            Text(errorMessage)
        }
    }
    
    private func renameTag() {
        let lowercasedTags = tags.map { $0.lowercased() }
        let trimmedRenamedTappedTag = renamedTappedTag.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawRenamedTappedTag = trimmedRenamedTappedTag.lowercased()
        
        if (indexOfTappedTag == -1) {
            errorMessage = "The tag was not found."
            showError = true
        } else {
            if (lowercasedTags.contains(rawRenamedTappedTag)) {
                errorMessage = "\(trimmedRenamedTappedTag) is already present in the list."
                showError = true
            } else {
                tags[indexOfTappedTag] = trimmedRenamedTappedTag
                clearVariables()
            }
        }
    }
    
    private func clearVariables() {
        tappedTag = ""
        renamedTappedTag = ""
        errorMessage = ""
        indexOfTappedTag = -1
        showAlert = false
        showError = false
    }
}

#Preview {
    TagsView(tags: .constant(["Tag 1", "Tag 2"]), buttonAction: { })
}
