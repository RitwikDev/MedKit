//
//  CustomFieldsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct IdentifiableUIImage: Identifiable {
    let id = UUID()
    let uiImage: UIImage
    
    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }
}

struct CustomFieldsSectionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    
    @State private var text: String = ""
    @State private var imageToPreview: IdentifiableUIImage?
    @State private var documentToPreview: Document?

    
    @FocusState private var focusedFieldID: UUID?
    @State private var editingFields = Set<UUID>()


    var body: some View {
        @Bindable var bindableViewModel = medicineEditorViewModel
        
        ForEach($bindableViewModel.medicine.customFields) { customField in
            Section(customField.wrappedValue.getLabel()) {
                switch customField.wrappedValue.definition?.dataType {
                case .text:
                    let textValue = customField.wrappedValue.textValue ?? ""
                    let isActivelyEditing = editingFields.contains(customField.wrappedValue.id)
                    let isFocused = focusedFieldID == customField.wrappedValue.id
                    let url = textValue.getUrl()
                    if let url, !isActivelyEditing, !isFocused {
                        HStack {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Text(textValue)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .buttonStyle(.borderless)
                            
                            Spacer()
                            
                            Button {
                                editingFields.insert(customField.wrappedValue.id)
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                    } else {
                        HStack {
                            TextField("Enter value", text: Binding(
                                get: { textValue },
                                set: { customField.wrappedValue.textValue = $0 }
                            ), axis: .vertical)

                            .focused($focusedFieldID, equals: customField.wrappedValue.id)
                            
                            if url != nil && isActivelyEditing {
                                Button {
                                    editingFields.remove(customField.wrappedValue.id);
                                    focusedFieldID = nil
                                } label: {
                                    Image(systemName: "checkmark")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }

                    
                case .date:
                    DatePicker("Select Date", selection: Binding(
                        get: { customField.wrappedValue.dateValue ?? .now },
                        set: { customField.wrappedValue.dateValue = $0 }
                    ), displayedComponents: .date)
                    
                case .list:
                    if let list = customField.wrappedValue.listValue {
                        HStack {
                            TextField("Write something...", text: $text)
                            CircularButtonView(
                                title: "Add",
                                systemImage: "plus",
                                tintColor: .blue
                            ) {
                                withAnimation {
                                    medicineEditorViewModel.addCustomListItem(
                                        to: customField.wrappedValue,
                                        value: text.trimmed,
                                    )
                                }
                                text = ""
                            }
                            .disabled(text.trimmedIsEmpty)
                        }
                        
                        ForEach(list, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { indexSet in
                            medicineEditorViewModel.deleteCustomListItem(from: customField.wrappedValue, at: indexSet)
                        }
                    }
                    
                case .documents:
                    if let documents = customField.wrappedValue.documentValue {
                        HorizontalCarouselView {
                            ForEach(documents) { document in
                                switch document.documentType {
                                case .photo:
                                    if let uiImage = UIImage(data: document.documentData) {
                                        ImageCarouselCellView(uiImage: uiImage) {
                                            bindableViewModel.deleteDocument(document)
                                        }
                                        .onTapGesture {
                                            imageToPreview = IdentifiableUIImage(uiImage)
                                        }
                                    } else {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .foregroundColor(.red)
                                    }
                                    
                                case .document:
                                    DocumentCarouselCellView(document: document) {
                                        bindableViewModel.deleteDocument(document)
                                    }
                                    .onTapGesture { documentToPreview = document }
                                }
                            }
                        }
                        .onChange(of: bindableViewModel.medicine.customFields) { _, newValue in
                            for newCustomField in newValue {
                                if let documents = newCustomField.documentValue {
                                    if (documents.isEmpty) {
                                        withAnimation {
                                            bindableViewModel.deleteCustomField(newCustomField)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                case .none:
                    EmptyView()
                }
            }
        }
        
        Button("Add Field") {
            router.navigate(to: .addCustomFields(medicineEditorViewModel: medicineEditorViewModel))
        }
        .fullScreenCover(item: $imageToPreview) { uiImage in
            ImagePreviewSheetView(uiImage: uiImage.uiImage) {
                imageToPreview = nil
            }
        }
        .fullScreenCover(item: $documentToPreview) { document in
            DocumentPreviewSheetView(document: document) {
                documentToPreview = nil
            }
        }
    }
}

#Preview {
    Form {
        CustomFieldsSectionView()
    }
    .environment(MedicineEditorViewModel(
        medicine: .init(
            customFields: [
                .init(
                    textValue: "Sherlock Holmes",
                    definition: .init(
                        label: "Show",
                        dataType: .text
                    )
                ),
                .init(
                    dateValue: Calendar.current.date(
                        from: .init(year: 1984, month: 4, day: 24)
                    ) ?? .now,
                    definition: .init(
                        label: "Date",
                        dataType: .date
                    )
                ),
                .init(
                    textListValue: [
                        "Jeremy Brett",
                        "David Burke",
                        "Edward Hardwicke"
                    ],
                    definition: .init(
                        label: "Actors",
                        dataType: .list
                    )
                ),
            ]
        )
    ))
    .environment(NavigationRouter())
}
