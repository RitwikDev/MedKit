//
//  ExtensionManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation
import SwiftUI

extension ManageMedicineTagsView {
    func handleOnAppear(
        allTags: [Tag],
        allTagsState: inout [Tag],
        filteredTags: inout [Tag],
        medicineTags: inout [Tag]
    ) {
        allTagsState = allTags
        filteredTags = allTags
        medicineTags = self.medicineViewModel.medicine.tags
    }
    
    func addNewTag(
        allTagsState: inout [Tag],
        medicineTags: inout [Tag],
        newTagValue: inout String
    ) {
        guard !newTagValue.trimmedIsEmpty else { return }
        
        let trimmedNewTag = newTagValue.trimmed
        let newTag = Tag(value: trimmedNewTag)

        allTagsState.append(newTag)
        medicineTags.append(newTag)
        
        allTagsState.sort { $0.value < $1.value }
        
        newTagValue = ""
    }
    
    func addExistingTag(
        allTagsState: inout [Tag],
        medicineTags: inout [Tag],
        tag: Tag,
        newTagValue: inout String
    ) {
        medicineTags.append(tag)
        newTagValue = ""
    }
    
    func removeTag(
        medicineTags: inout [Tag],
        tagToRemove: Tag
    ) {
        medicineTags.removeAll { $0.equals(tagToRemove) }
    }
    
    func filterIn(
        allTagsState: inout [Tag],
        filteredTags: inout [Tag],
        newTagValue: String
    ) {
        if (newTagValue.trimmedIsEmpty) {
            filteredTags = allTagsState
        } else {
            filteredTags = allTagsState.filter { $0.value.localizedCaseInsensitiveContains(newTagValue) }
        }
    }
    
    func handleSave(medicineTags: [Tag]) {
        self.medicineViewModel.medicine.tags = medicineTags
    }
}
