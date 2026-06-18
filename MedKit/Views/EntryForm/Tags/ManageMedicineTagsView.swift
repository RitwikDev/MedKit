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
    @Environment(\.dismiss) private var dismiss
    @Environment(MedicineViewModel.self) var medicineViewModel
    
    @State private var allTagsState: [Tag] = []
    @State private var filteredTags: [Tag] = []
    // TODO: - Store medicineTags in a Set
    @State private var medicineTags: [Tag] = []
    @State private var newTagValue: String = ""
    @State private var showUnsavedChangesConfirmationDialog: Bool = false
    
    var body: some View {
        Form {
            tagTextFieldView
            addTagButtonView
            allTagsView
        }
        .onAppear {
            handleOnAppear(
                medicineViewModel: self.medicineViewModel,
                allTagModels: allTagModels,
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
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Manage Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var tagTextFieldView: some View {
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
    
    private var addTagButtonView: some View {
        Button("Add \(newTagValue)") {
            withAnimation {
                addNewTag(
                    allTagsState: &allTagsState,
                    medicineTags: &medicineTags,
                    newTagValue: &newTagValue
                )
            }
        }
        .disabled(isAddButtonDisabled(allTagsState: allTagsState, newTagValue: newTagValue))
    }
    
    private var allTagsView: some View {
        Section("All Tags") {
            if (filteredTags.isEmpty) {
                EmptyEntryView(text: allTagsState.isEmpty ? "No Tags Added" : "No Results Found")
            } else {
                ForEach(filteredTags) { tag in
                    if (self.medicineTags.firstIndex { $0.equals(tag) } != nil) {
                        tagExistsInMedicineView(tag)
                    } else {
                        tagDoesNotExistInMedicineView(tag)
                    }
                }
            }
        }
    }
    
    private func tagExistsInMedicineView(_ tag: Tag) -> some View {
        HStack {
            Text(tag.value)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.blue)
        }
        .swipeActions {
            Button("Remove") {
                withAnimation {
                    removeTag(medicineTags: &medicineTags, tagToRemove: tag)
                }
            }
            .tint(.red)
        }
    }
    
    private func tagDoesNotExistInMedicineView(_ tag: Tag) -> some View {
        Text(tag.value)
            .swipeActions(edge: .leading) {
                Button("Add") {
                    withAnimation {
                        addExistingTag(
                            allTagsState: &allTagsState,
                            medicineTags: &medicineTags,
                            tag: tag,
                            newTagValue: &newTagValue
                        )
                    }
                }
                .tint(.blue)
            }
    }
    
    private var confirmationToolbarItem: some View {
        Button("Done") {
            if (newTagValue.trimmedIsEmpty) {
                handleSave(medicineViewModel: medicineViewModel, medicineTags: medicineTags)
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
                handleSave(medicineViewModel: medicineViewModel, medicineTags: medicineTags)
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
