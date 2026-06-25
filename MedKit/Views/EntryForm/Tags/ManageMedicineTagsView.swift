//
//  ManageMedicineTagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftData
import SwiftUI

struct ManageMedicineTagsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GlobalDataViewModel.self) var globalDataViewModel
    @Environment(MedicineEditorViewModel.self) var medicineEditorViewModel
    
    @State private var filteredTags: [Tag] = []
    @State private var medicineTags: Set<Tag> = []
    @State private var newTagValue: String = ""
    
    private var isDoneButtonDisabled: Bool {
        globalDataViewModel.allTags.first { $0.value.trimmedLocalizedCaseInsensitiveEquals(newTagValue) } != nil
    }
    
    var body: some View {
        Form {
            tagTextFieldView
            allTagsView
        }
        .onAppear {
            handleOnAppear(
                globalDataViewModel: globalDataViewModel,
                medicineEditorViewModel: medicineEditorViewModel,
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
                            globalDataViewModel: globalDataViewModel,
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
                EmptyEntryView(text: globalDataViewModel.allTags.isEmpty ? "No Tags Added" : "No Results Found")
            } else {
                ForEach(filteredTags) { tag in
                    if (self.medicineTags.contains(tag)) {
                        tagExistsInMedicineView(tag)
                    } else {
                        tagDoesNotExistInMedicineView(tag)
                    }
                }
            }
        }
    }
    
    private func tagExistsInMedicineView(_ tag: Tag) -> some View {
        Button {
            withAnimation {
                removeTag(medicineTags: &medicineTags, tagToRemove: tag)
            }
        } label: {
            HStack {
                Text(tag.value)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .tint(.primary)
    }
    
    private func tagDoesNotExistInMedicineView(_ tag: Tag) -> some View {
        Button {
            withAnimation {
                addExistingTag(
                    medicineTags: &medicineTags,
                    tagToAdd: tag,
                    newTagValue: &newTagValue
                )                
            }
        } label: {
            Text(tag.value)
        }
        .tint(.primary)
    }
    
    private var confirmationToolbarItem: some View {
        Button("Done") {
            addNewTag(
                globalDataViewModel: globalDataViewModel,
                medicineTags: &medicineTags,
                newTagValue: &newTagValue
            )
            
            handleSave(
                medicineEditorViewModel: medicineEditorViewModel,
                medicineTags: medicineTags
            )
            
            dismiss()
        }
        .disabled(isDoneButtonDisabled)
    }
}

#Preview {
    NavigationStack {
        ManageMedicineTagsView()
            .environment(GlobalDataViewModel())
            .environment(MedicineEditorViewModel())
    }
}
