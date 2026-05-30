//
//  ManageMedicineTagsSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftData
import SwiftUI

struct ManageMedicineTagsSheetView: View {
    @State var medicineTags: [Tag]
    @State var allTags: [Tag]
    let onSave: ([Tag]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @State private var otherTags: [Tag] = []
    @State private var newTagValue: String = ""
    @State private var showUnsavedChangesConfirmationDialog: Bool = false
    
    private var dynamicHeight: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large:
            return 200
        case .xLarge, .xxLarge, .xxxLarge:
            return 225
        case .accessibility1:
            return 235
        case .accessibility2:
            return 260
        case .accessibility3:
            return 285
        case .accessibility4:
            return 325
        case .accessibility5:
            return 345
        @unknown default:
            return 200
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    addTagView
                }
                .frame(maxHeight: dynamicHeight)
                .scrollDisabled(true)
                
                Form {
                    currentTagsView
                    otherTagsView
                }
            }
            .onAppear{ handleOnAppear(otherTags: &otherTags) }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if (newTagValue.trimmedIsEmpty) {
                            onSave(medicineTags)
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
                            onSave(medicineTags)
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you do not want to save \(newTagValue)?")
                    }
                }
            }
            .sheetModifier(titled: "Manage Tags")
        }
    }
    
    private var addTagView: some View {
        Group {
            Section("New Tag") {
                TextField("Tag", text: $newTagValue)
                    .task(id: newTagValue) {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        
                        withAnimation {
                            filterTags(newTagValue: &newTagValue, otherTags: &otherTags)
                        }
                    }
            }
            
            Button("Add") {
                addNewCustomTag(newTagValue: &newTagValue, otherTags: &otherTags)
            }
            .disabled(disableAddButton(newTagValue: newTagValue))
        }
    }
    
    private var currentTagsView: some View {
        Section("This Medicine's Tags") {
            if (!medicineTags.isEmpty) {
                ForEach(medicineTags) { tag in
                    Text(tag.value)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                remove(newTagValue: &newTagValue, tag: tag, otherTags: &otherTags)
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
                        }
                }
            } else {
                EmptyEntryView(text: "No Tags Added")
            }
        }
    }
    
    private var otherTagsView: some View {
        Section("Other Tags") {
            if (!otherTags.isEmpty) {
                ForEach(otherTags) { tag in
                    Text(tag.value)
                        .swipeActions(edge: .trailing) {
                            Button {
                                add(newTagValue: &newTagValue, tag: tag, otherTags: &otherTags)
                            } label: {
                                Label("Add", systemImage: "plus.circle")
                            }
                            .tint(.blue)
                        }
                }
            } else {
                EmptyEntryView(text: newTagValue.isEmpty ? "No Other Tags Added" : "No Results Found")
            }
        }
    }
}

#Preview {
    ManageMedicineTagsSheetView(
        medicineTags: [],
        allTags: [],
        onSave: { _ in }
    )
}
