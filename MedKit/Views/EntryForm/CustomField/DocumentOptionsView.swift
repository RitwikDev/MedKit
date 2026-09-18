//
//  DocumentOptionsView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct DocumentOptionsView: View {
    @Binding var customFieldValue: CustomFieldValue
    @Binding var selectedUIImages: [UIImageDocument]
    @Binding var selectedDocuments: [Document]
    let medicineEditorViewModel: MedicineEditorViewModel
    
    @State private var showFilePicker = false
    @State private var showProgressView: Bool = false
    @State private var showDocumentAlert = false
    @State private var errorMessage: String = ""
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedDocumentsUrls: [UUID: URL] = [:] // Needing to do this as the URL of the document is not being saved in the database.
    
    var body: some View {
        Group {
            if (showProgressView) {
                ProgressView()
            } else {
                PhotosPicker("Choose Photos", selection: $selectedPhotoItems, maxSelectionCount: 5, matching: .images)
                Button("Choose from Files") { showFilePicker = true }
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItem in
            Task {
                await handlePhotoSelection(photoPickerItems: newItem)
            }
        }
        .alert(
            "Something went wrong",
            isPresented: $showDocumentAlert
        ) { } message: {
            Text(errorMessage)
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf, .text, .image, .spreadsheet, .pages, .docx],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                do {
                    resetDocumentVariables()
                    for url in urls {
                        let safeData = try medicineEditorViewModel.extractData(from: url)
                        let document = Document(
                            name: url.deletingPathExtension().lastPathComponent,
                            documentExtension: url.pathExtension,
                            documentData: safeData,
                            documentType: .document
                        )
                        
                        withAnimation {
                            selectedDocumentsUrls[document.id] = url
                            selectedDocuments.append(document)
                        }
                    }
                    customFieldValue.documentValue = selectedDocuments
                } catch {
                    withAnimation {
                        customFieldValue.documentValue = nil
                        errorMessage = error.localizedDescription
                        showDocumentAlert = true
                    }
                }
                
            case .failure(let error):
                errorMessage = error.localizedDescription
                showDocumentAlert = true
                resetDocumentVariables()
            }
        }
    }
    
    private func handlePhotoSelection(photoPickerItems: [PhotosPickerItem]) async {
        resetDocumentVariables()
        showProgressView = true
        
        do {
            for photoPickerItem in photoPickerItems {
                if let data = try await photoPickerItem.loadTransferable(type: Data.self) {
                    try medicineEditorViewModel.validateImageData(data)
                    
                    let id: UUID = UUID()
                    
                    await loadUIImage(from: photoPickerItem, id: id)
                    
                    let document = Document(
                        id: id,
                        name: "Photo",
                        documentExtension: photoPickerItem.supportedContentTypes.first?.preferredFilenameExtension ?? "unknown",
                        documentData: data,
                        documentType: .photo
                    )
                    showProgressView = false
                    
                    withAnimation {
                        selectedDocuments.append(document)
                    }
                }
            }
            customFieldValue.documentValue = selectedDocuments
        } catch {
            withAnimation {
                showProgressView = false
                errorMessage = error.localizedDescription
                showDocumentAlert = true
                resetDocumentVariables()
            }
        }
    }
    
    private func loadUIImage(from item: PhotosPickerItem?, id: UUID) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                withAnimation {
                    self.selectedUIImages.append(UIImageDocument(id: id, image: uiImage))
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showDocumentAlert = true
        }
    }
    
    private func resetDocumentVariables() {
        selectedDocuments = []
        selectedPhotoItems = []
        selectedUIImages = []
        selectedDocumentsUrls = [:]
    }
}

#Preview {
    Form {
        DocumentOptionsView(
            customFieldValue: .constant(.init()),
            selectedUIImages: .constant([]),
            selectedDocuments: .constant([]),
            medicineEditorViewModel: .init()
        )
    }
}
