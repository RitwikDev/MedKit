//
//  ExtensionManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation
import SwiftUI

extension ManageMedicineTagsView {
    func handleOnAppear(otherTags: inout [Tag]) {
        let medicineTagsSet = Set(self.medicineViewModel.medicine.tags.map { $0.value.lowercasedAndTrimmed })
        otherTags = allTags.filter { !medicineTagsSet.contains($0.value.lowercasedAndTrimmed) }
        self.allTagsState = allTags
        self.medicineTags = self.medicineViewModel.medicine.tags
    }
    
    func add(newTagValue: inout String, tag: Tag, otherTags: inout [Tag]) {
        withAnimation {
            self.medicineTags.append(tag)
            filterTags(newTagValue: &newTagValue, otherTags: &otherTags)
        }
    }
    
    func remove(newTagValue: inout String, tag: Tag, otherTags: inout [Tag]) {
        withAnimation {
            self.medicineTags.removeAll { $0.equals(tag) }
            otherTags.append(tag)
            filterTags(newTagValue: &newTagValue, otherTags: &otherTags)
        }
    }
    
    func addNewCustomTag(newTagValue: inout String, otherTags: inout [Tag]) {
        let cleanedNewTagValue = newTagValue.trimmed
        guard !cleanedNewTagValue.isEmpty else { return }
        
        if let existingTag = allTags.first(where: { $0.value.localizedCaseInsensitiveCompare(cleanedNewTagValue) == .orderedSame }) {
            if (!self.medicineTags.contains(existingTag)) {
                add(newTagValue: &newTagValue, tag: existingTag, otherTags: &otherTags)
            }
        } else {
            let newTag = Tag(value: cleanedNewTagValue)
            self.allTagsState.append(newTag)
            add(newTagValue: &newTagValue, tag: newTag, otherTags: &otherTags)
        }
        
        newTagValue = ""
    }
    
    func filterTags(newTagValue: inout String, otherTags: inout [Tag]) {
        let excludedTags = Set(self.medicineTags.map { $0.value.lowercasedAndTrimmed })
        
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
        
        let isTagPresent = self.medicineTags.contains { tag in
            tag.value.localizedCaseInsensitiveCompare(cleanedNewTagValue) == .orderedSame
        }
        
        return cleanedNewTagValue.isEmpty || isTagPresent
    }
    
    func handleSave() {
        self.medicineViewModel.medicine.tags = self.medicineTags
    }
}
