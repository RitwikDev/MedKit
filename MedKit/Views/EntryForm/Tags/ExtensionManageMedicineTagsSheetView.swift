//
//  ExtensionManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation

extension ManageMedicineTagsView {
    func handleOnAppear(
        globalDataViewModel: GlobalDataViewModel,
        medicineEditorViewModel: MedicineEditorViewModel,
        filteredTags: inout [Tag],
        medicineTags: inout Set<Tag>
    ) {
        filteredTags = globalDataViewModel.allTags
        medicineTags = Set(medicineEditorViewModel.medicine.tags)
    }
    
    func addNewTag(
        globalDataViewModel: GlobalDataViewModel,
        medicineTags: inout Set<Tag>,
        newTagValue: inout String
    ) {
        guard !newTagValue.trimmedIsEmpty else { return }
        
        let trimmedNewTag = newTagValue.trimmed
        let newTag = Tag(value: trimmedNewTag)

        globalDataViewModel.allTags.append(newTag)
        medicineTags.insert(newTag)
        
        newTagValue = ""
    }
    
    func addExistingTag(
        medicineTags: inout Set<Tag>,
        tagToAdd: Tag,
        newTagValue: inout String
    ) {
        medicineTags.insert(tagToAdd)
        newTagValue = ""
    }
    
    func removeTag(
        medicineTags: inout Set<Tag>,
        tagToRemove: Tag
    ) {
        medicineTags.remove(tagToRemove)
    }
    
    func filterIn(
        globalDataViewModel: GlobalDataViewModel,
        filteredTags: inout [Tag],
        newTagValue: String
    ) {
        if (newTagValue.trimmedIsEmpty) {
            filteredTags = globalDataViewModel.allTags.sorted()
        } else {
            filteredTags = globalDataViewModel.allTags.filter { $0.value.localizedCaseInsensitiveContains(newTagValue) }
        }
    }
    
    func handleSave(
        medicineEditorViewModel: MedicineEditorViewModel,
        medicineTags: Set<Tag>
    ) {
        medicineEditorViewModel.medicine.tags = Array(medicineTags).sorted()
    }
}
