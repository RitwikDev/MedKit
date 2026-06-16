//
//  ManageMedicineTagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftData
import SwiftUI

struct ManageMedicineTagsView: View {
    @Query(sort: \TagModel.value) private var allTagModels: [TagModel]
    
    private var allTags: [Tag] {
        allTagModels.map { Tag(from: $0) }
    }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineViewModel.self) var medicineViewModel
    
    @State private var allTagsState: [Tag] = []
    @State private var filteredTags: [Tag] = []
    @State private var medicineTags: [Tag] = []
    @State private var newTagValue: String = ""
    @State private var showUnsavedChangesConfirmationDialog: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                tagTextField
                allTagsView
            }
        }
        .onAppear{
            handleOnAppear(
                allTags: allTags,
                allTagsState: &allTagsState,
                filteredTags: &filteredTags,
                medicineTags: &medicineTags
            )
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                confirmationToolbarItem
            }
        }
        .navigationTitle("Manage Tags")
    }
    
    private var tagTextField: some View {
        Section("New Tag") {
            TextField("Tag", text: $newTagValue)
                .onChange(of: newTagValue) { oldValue, newValue in
                    withAnimation {
                        filterIn(
                            allTagsState: &allTagsState,
                            filteredTags: &filteredTags,
                            newTagValue: newValue.trimmed,
                        )
                    }
                }
        }
    }
    
    private var allTagsView: some View {
        Section("All Tags") {
            if (filteredTags.isEmpty) {
                Button("Add \(newTagValue)") {
                    withAnimation {
                        addNewTag(
                            allTagsState: &allTagsState,
                            medicineTags: &medicineTags,
                            newTagValue: &newTagValue
                        )
                    }
                }
            } else {
                ForEach(filteredTags) { tag in
                    if (self.medicineTags.firstIndex { $0.equals(tag) } != nil) {
                        tagExistsInMedicineView(tag: tag)
                    } else {
                        tagDoesNotExistInMedicineView(tag: tag)
                    }
                }
            }
        }
    }
    
    private func tagExistsInMedicineView(tag: Tag) -> some View {
        Button {
            removeTag(medicineTags: &medicineTags, tagToRemove: tag)
        } label: {
            HStack {
                Text(tag.value)
                
                if (self.medicineTags.firstIndex { $0.equals(tag) } != nil) {
                    Spacer()
                    Image(systemName: "checkmark")
                        .tint(.blue)
                }
            }
        }
        .tint(.primary)
    }
    
    private func tagDoesNotExistInMedicineView(tag: Tag) -> some View {
        Button {
            addExistingTag(
                allTagsState: &allTagsState,
                medicineTags: &medicineTags,
                tag: tag,
                newTagValue: &newTagValue
            )
        } label: {
            Text(tag.value)
        }
        .tint(.primary)
    }
    
    private var confirmationToolbarItem: some View {
        Button("Done") {
            if (newTagValue.trimmedIsEmpty) {
                handleSave(medicineTags: medicineTags)
                dismiss()
            } else {
                showUnsavedChangesConfirmationDialog.toggle()
            }
        }
        .confirmationDialog(
            "You have some unsaved changes",
            isPresented: $showUnsavedChangesConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                handleSave(medicineTags: medicineTags)
                dismiss()
            }
        } message: {
            Text("Are you sure you do not want to save \(newTagValue)?")
        }
    }
}

#Preview {
    NavigationStack {
        ManageMedicineTagsView()
            .modelContainer(PreviewData.container)
            .environment(MedicineViewModel())
    }
}
