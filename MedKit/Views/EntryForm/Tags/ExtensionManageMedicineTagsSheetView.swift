//
//  ExtensionManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation
import SwiftUI

extension ManageMedicineTagsSheetView {
    func handleOnAppear(otherTags: inout [Tag]) {
        let excluded = Set(medicineTags.map { $0.value.lowercasedAndTrimmed })
        otherTags = allTags.filter { !excluded.contains($0.value.lowercasedAndTrimmed) }
    }
    
    func add(newTagValue: inout String, tag: Tag, otherTags: inout [Tag]) {
        withAnimation {
            medicineTags.append(tag)
            filterTags(newTagValue: &newTagValue, otherTags: &otherTags)
        }
    }
    
    func remove(newTagValue: inout String, tag: Tag, otherTags: inout [Tag]) {
        withAnimation {
            medicineTags.removeAll { $0.equals(tag) }
            otherTags.append(tag)
            filterTags(newTagValue: &newTagValue, otherTags: &otherTags)
        }
    }
    
    func addNewCustomTag(newTagValue: inout String, otherTags: inout [Tag]) {
        let cleanedNewTagValue = newTagValue.trimmed
        guard !cleanedNewTagValue.isEmpty else { return }
        
        if let existingTag = allTags.first(where: { $0.value.localizedCaseInsensitiveCompare(cleanedNewTagValue) == .orderedSame }) {
            if (!medicineTags.contains(existingTag)) {
                add(newTagValue: &newTagValue, tag: existingTag, otherTags: &otherTags)
            }
        } else {
            let newTag = Tag(value: cleanedNewTagValue)
            allTags.append(newTag)
            add(newTagValue: &newTagValue, tag: newTag, otherTags: &otherTags)
        }
        
        newTagValue = ""
    }
    
    func filterTags(newTagValue: inout String, otherTags: inout [Tag]) {
        let excludedTags = Set(medicineTags.map { $0.value.lowercasedAndTrimmed })
        
        if (newTagValue.trimmedIsEmpty) {
            otherTags = allTags.filter { !excludedTags.contains($0.value.lowercasedAndTrimmed) }
        } else {
            otherTags = allTags.filter { tag in
                tag.value.localizedCaseInsensitiveContains(newTagValue.trimmed) &&
                !excludedTags.contains(tag.value.lowercasedAndTrimmed)
            }
        }
    }
    
    func disableAddButton(newTagValue: String) -> Bool {
        let cleanedNewTagValue = newTagValue.lowercasedAndTrimmed
        
        let isTagPresent = medicineTags.contains { tag in
            tag.value.localizedCaseInsensitiveCompare(cleanedNewTagValue) == .orderedSame
        }
        
        return cleanedNewTagValue.isEmpty || isTagPresent
    }
}
