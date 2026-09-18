//
//  MedicineCustomFieldFormView.swift
//  MedKit
//
//  Created by Ritwik Dev on 14/06/26.
//

import PhotosUI
import SwiftUI

private struct TextFieldListItem: Identifiable, Equatable {
    var id = UUID()
    var text: String
}

struct UIImageDocument: Identifiable, Equatable, Hashable {
    var id: UUID
    var image: UIImage
}

struct MedicineCustomFieldFormView: View {
    let medicineEditorViewModel: MedicineEditorViewModel
    let customFieldDefinition: CustomField
    @Binding var customFieldValue: CustomFieldValue
    
    @State private var text: String = ""
    @State private var date: Date = .now
    @State private var textList: [TextFieldListItem] = []
    @State private var selectedUIImages: [UIImageDocument] = []
    @State private var imageToPreview: IdentifiableUIImage?
    @State private var selectedDocuments: [Document] = []
    @State private var documentToPreview: Document?
    
    @FocusState private var focusedFieldID: UUID?
    
    var body: some View {
        Form {
            Section(customFieldDefinition.label) {
                switch customFieldDefinition.dataType {
                case .text:
                    TextField("Write something...", text: $text, axis: .vertical)
                        .lineLimit(5)
                case .date:
                    DatePicker("Choose date", selection: $date, displayedComponents: .date)
                case .list:
                    listOptions
                case .documents:
                    DocumentOptionsView(
                        customFieldValue: $customFieldValue,
                        selectedUIImages: $selectedUIImages,
                        selectedDocuments: $selectedDocuments,
                        medicineEditorViewModel: medicineEditorViewModel
                    )
                }
            }
            
            if (customFieldValue.documentValue != nil) {
                Section("Preview") {
                    documentPreviewView
                }
            }
            
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            customFieldValue.definition = customFieldDefinition
            customFieldValue.textValue = nil
            customFieldValue.dateValue = nil
            customFieldValue.listValue = nil
            customFieldValue.documentValue = nil
        }
        .onChange(of: text) { oldValue, newValue in
            // This condition is required because self.text is being reused for self.textList
            if customFieldDefinition.dataType == .text {
                customFieldValue.textValue = newValue
            }
        }
        .onChange(of: date) { oldValue, newValue in
            customFieldValue.dateValue = newValue
        }
        .onChange(of: textList) { oldValue, newValue in
            customFieldValue.listValue = newValue.map { $0.text.trimmed }
        }
        .sheet(item: $imageToPreview) { uiImage in
            ImagePreviewSheetView(uiImage: uiImage.uiImage) {
                imageToPreview = nil
            }
        }
        .sheet(item: $documentToPreview) { document in
            DocumentPreviewSheetView(document: document) {
                documentToPreview = nil
            }
        }
    }
    
    private var listOptions: some View {
        Group {
            HStack {
                TextField("Write something...", text: $text)
                CircularButtonView(
                    title: "Add",
                    systemImage: "plus",
                    tintColor: .blue
                ) {
                    withAnimation {
                        textList.append(.init(text: text.trimmed))
                    }
                    text = ""
                }
                .disabled(text.trimmedIsEmpty)
            }
            
            ForEach($textList) { $textItem in
                TextField("Write something...", text: $textItem.text)
                    .focused($focusedFieldID, equals: textItem.id)
            }
            .onDelete(perform: deleteListItems)
        }
        .onChange(of: focusedFieldID) { oldFocusedID, newFocusedID in
            if let lostFocusID = oldFocusedID {
                if let index = textList.firstIndex(where: { $0.id == lostFocusID }) {
                    if textList[index].text.trimmedIsEmpty {
                        withAnimation {
                            _ = textList.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    private var documentPreviewView: some View {
        Group {
            if !(selectedUIImages.isEmpty) {
                HorizontalCarouselView {
                    ForEach(selectedUIImages, id: \.self) { selectedUIImage in
                        ImageCarouselCellView(uiImage: selectedUIImage.image) {
                            withAnimation {
                                selectedUIImages.removeAll { $0 == selectedUIImage }
                                selectedDocuments.removeAll { $0.id == selectedUIImage.id }
                                customFieldValue.documentValue = selectedDocuments
                            }
                        }
                        .onTapGesture {
                            imageToPreview = IdentifiableUIImage(selectedUIImage.image)
                        }
                    }
                }
            } else if !(selectedDocuments.isEmpty) {
                HorizontalCarouselView {
                    ForEach(selectedDocuments, id: \.self) { selectedDocument in
                        DocumentCarouselCellView(document: selectedDocument) {
                            withAnimation {
                                selectedDocuments.removeAll { $0.id == selectedDocument.id }
                                customFieldValue.documentValue = selectedDocuments
                            }
                        }
                        .onTapGesture {
                            documentToPreview = selectedDocument
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func deleteListItems(_ indexSet: IndexSet) {
        textList.remove(atOffsets: indexSet)
    }
}

#Preview {
    MedicineCustomFieldFormView(
        medicineEditorViewModel: .init(),
        customFieldDefinition: .init(label: "Actors", dataType: .list),
        customFieldValue: .constant(.init())
    )
}
