//
//  ReadOnlyMedicineFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 04/10/26.
//

import SwiftUI

struct ReadOnlyMedicineFormView: View {
    let medicine: Medicine
    
    @State private var imageToPreview: IdentifiableUIImage?
    @State private var documentToPreview: Document?
    
    var body: some View {
        Form {
            Section("Name") {
                Text(medicine.name)
            }
            
            strengthSectionView()
            
            datesSectionView()
                .disabled(true)
            
            if (!medicine.composition.isEmpty) {
                Section("Composition") {
                    ForEach(medicine.composition) { ingredient in
                        Text(ingredient.fullName)
                    }
                }
            }
            
            if let stock = medicine.stock {
                Section("Stock") {
                    Text(stock.quantity.formatted(.number))
                    Text(stock.unit)
                }
            }
            
            if let dosage = medicine.dosage {
                Section("Dosage") {
                    MedicineDosageHelper.dosageSummary(for: dosage, of: medicine)
                }
            }
            
            if (!medicine.tags.isEmpty) {
                Section("Tags") {
                    ForEach(medicine.tags) { tag in
                        Text(tag.value)
                    }
                }
            }
            
            if (!medicine.customFields.isEmpty) {
                customFieldsSectionView()
            }
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
        .navigationTitle(medicine.name)
    }
    
    @ViewBuilder
    private func datesSectionView() -> some View {
        if let manufacturedDate = medicine.manufacturedDate,
           let expiryDate = medicine.expiryDate {
            Section("Dates") {
                DatePickerView(label: "Manufacture Date", date: .constant(manufacturedDate))
                DatePickerView(label: "Expiry Date", date: .constant(expiryDate))
            }
        } else if let manufacturedDate = medicine.manufacturedDate {
            Section("Date") {
                DatePickerView(label: "Manufacture Date", date: .constant(manufacturedDate))
            }
        } else if let expiryDate = medicine.expiryDate {
            Section("Date") {
                DatePickerView(label: "Expiry Date", date: .constant(expiryDate))
            }
        }        
    }
    
    @ViewBuilder
    private func strengthSectionView() -> some View {
        if let strengthAmount = medicine.strengthAmount,
           let strengthUnit = medicine.strengthUnit {
            Section("Strength") {
                Text("\(strengthAmount.formatted(.number)) \(strengthUnit)")
            }
        }
    }
    
    @ViewBuilder
    private func customFieldsSectionView() -> some View {
        ForEach(medicine.customFields) { customField in
            Section(customField.getLabel()) {
                switch customField.definition?.dataType {
                case .text:
                    let textValue = customField.textValue ?? ""
                    let url = textValue.getUrl()
                    if let url {
                        HStack {
                            Button {
                                UIApplication.shared.open(url)
                            } label: {
                                Text(textValue)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .buttonStyle(.borderless)
                        }
                    } else {
                        Text(textValue)
                    }

                    
                case .date:
                    if let date = customField.dateValue {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                    
                case .list:
                    if let list = customField.listValue {
                        ForEach(list, id: \.self) { item in
                            Text(item)
                        }
                    }
                    
                case .documents:
                    if let documents = customField.documentValue {
                        HorizontalCarouselView {
                            ForEach(documents) { document in
                                switch document.documentType {
                                case .photo:
                                    if let uiImage = UIImage(data: document.documentData) {
                                        ImageCarouselCellView(uiImage: uiImage, showDeleteButton: false)
                                            .onTapGesture { imageToPreview = IdentifiableUIImage(uiImage) }
                                    } else {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .foregroundColor(.red)
                                    }
                                    
                                case .document:
                                    DocumentCarouselCellView(document: document, showDeleteButton: false)
                                        .onTapGesture { documentToPreview = document }
                                }
                            }
                        }
                    }
                    
                case .none:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReadOnlyMedicineFormView(
            medicine: .init(
                name: "Paracetamol",
                manufacturedDate: .now,
                expiryDate: .now,
                strengthAmount: 100,
                strengthUnit: "mcg",
                composition: [
                    .init(name: "Ingredient 1", strengthAmount: 20, strengthUnit: "mcg"),
                    .init(name: "Ingredient 2", strengthAmount: 50, strengthUnit: "ml"),
                ],
                dosage: .init(dosageQuantity: 1, startDate: .now, reminderTimes: [.init(time: .now)], repeatType: .daily, selectedDays: [], selectedDates: []),
                stock: .init(quantity: 10, unit: "Tablet"),
                isOnShoppingList: false,
                tags: [
                    .init(value: "Cough"),
                    .init(value: "Cold"),
                    .init(value: "Itch"),
                ],
                customFields: [
                    .init(textValue: "Spring Valley", definition: .init(label: "Company", dataType: .text)),
                    .init(textListValue: ["Hair Loss", "Nausea"], definition: .init(label: "Side Effects", dataType: .list)),
                ],
                doseLogs: []
            )
        )
    }
}
