//
//  MedicineEditorViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//

import CloudKit
import SwiftUI

enum AttachmentError: LocalizedError {
    case fileTooLarge
    case unreadableFile
    
    var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            return "Please select a file smaller than 5MB to ensure your medicine database syncs reliably to iCloud."
        case .unreadableFile:
            return "The selected file could not be read. Please try another."
        }
    }
}

struct ValidationError: LocalizedError {
    let errorDescription: String?
}

struct ShareContext: Identifiable {
    let id = UUID()
    let share: CKShare
    let container: CKContainer
}

/// Powers the medicine creation and editing form.
/// Acts as a temporary scratchpad until the user taps "Save".
@Observable
@MainActor
class MedicineEditorViewModel {
    
    /// The temporary draft being edited on screen.
    var medicine: Medicine
    var errorMessage: String?
    
    private var maxFileSizeInBytes: Int { 5 * 1024 * 1024 }

    /// Initialises the editor. Pass an existing medicine to edit, or nil to create a new one.
    init(medicine: Medicine = .init()) {
        self.medicine = medicine
    }

    // MARK: - Ingredient Management
    
    func upsertIngredient(_ ingredient: Ingredient) {
        if let index = medicine.composition.firstIndex(where: { $0.id == ingredient.id }) {
            // Update existing
            medicine.composition[index] = ingredient
        } else {
            // Add new
            medicine.composition.append(ingredient)
        }
        
        medicine.composition.sort()
    }

    func removeIngredient(at offsets: IndexSet) {
        medicine.composition.remove(atOffsets: offsets)
    }
    
    // MARK: - Dosage Management
    
    func removeDosage() {
        medicine.dosage = nil
    }

    // MARK: - Tag Management
    
    func addTag(_ tag: Tag) {
        if !(medicine.tags.contains(tag)) {
            medicine.tags.append(tag)
            medicine.tags.sort()
        }
    }
    
    func removeTag(at offsets: IndexSet) {
        medicine.tags.remove(atOffsets: offsets)
    }
    
    // MARK: - Custom Fields
    
    func addCustomField(_ customField: CustomFieldValue) {
        medicine.customFields.append(customField)
        medicine.customFields.sort()
    }
    
    func addCustomListItem(to customField: CustomFieldValue, value: String) {
        guard let fieldIndex = medicine.customFields.firstIndex(where: { $0.id == customField.id }) else {
            return
        }
        
        var updatedList = medicine.customFields[fieldIndex].listValue ?? []
        updatedList.append(value)
        
        medicine.customFields[fieldIndex].listValue = updatedList
    }
    
    func deleteCustomListItem(from customField: CustomFieldValue, at indexSet: IndexSet) {
        guard let fieldIndex = medicine.customFields.firstIndex(where: { $0.id == customField.id }) else {
            return
        }
        
        var updatedList = medicine.customFields[fieldIndex].listValue ?? []
        updatedList.remove(atOffsets: indexSet)
        
        medicine.customFields[fieldIndex].listValue = updatedList
    }
    
    func deleteCustomField(_ customFieldToDelete: CustomFieldValue) {
        medicine.customFields.removeAll { $0.id == customFieldToDelete.id }
    }
    
    func deleteDocument(_ documentToDelete: Document) {
        for index in medicine.customFields.indices {
            if var existingDocuments = medicine.customFields[index].documentValue {
                existingDocuments.removeAll { $0.id == documentToDelete.id }
                medicine.customFields[index].documentValue = existingDocuments
            }
        }
    }
    
    // MARK: - File Attachment Logic
    
    /// Validates a file URL and extracts its data if it is safe to upload.
    func extractData(from url: URL) throws -> Data {
        guard url.startAccessingSecurityScopedResource() else {
            throw AttachmentError.unreadableFile
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let resources = try url.resourceValues(forKeys: [.fileSizeKey])
            guard let fileSize = resources.fileSize else {
                throw AttachmentError.unreadableFile
            }
            
            if fileSize > maxFileSizeInBytes {
                throw AttachmentError.fileTooLarge
            }
            
            return try Data(contentsOf: url)
        } catch {
            throw error
        }
    }
    
    /// Validates raw data extracted from a PhotosPicker.
    func validateImageData(_ data: Data) throws {
        if data.count > maxFileSizeInBytes {
            throw AttachmentError.fileTooLarge
        }
    }
    
    // MARK: - Database Handoff
    
    /// Validates the draft and hands the finalised pure struct to the Manager for database persistence.
    func saveMedicine() throws {
        let trimmedName = medicine.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Medicine name is required."
            throw ValidationError(errorDescription: errorMessage)
        }
        
        let invalidCharacters = CharacterSet.alphanumerics.union(.whitespaces).inverted
        guard trimmedName.rangeOfCharacter(from: invalidCharacters) == nil else {
            errorMessage = "Medicine name must not contain special characters."
            throw ValidationError(errorDescription: errorMessage)
        }
        
        if let mfgDate = medicine.manufacturedDate, let expDate = medicine.expiryDate {
            guard mfgDate < expDate else {
                errorMessage = "Manufactured date must precede the expiry date."
                throw ValidationError(errorDescription: errorMessage)
            }
        }
        
        let hasStrengthAmount = (medicine.strengthAmount != nil)
        let hasStrengthUnit = !(medicine.strengthUnit ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if hasStrengthAmount != hasStrengthUnit {
            errorMessage = "Both strength value and unit must be provided together."
            throw ValidationError(errorDescription: errorMessage)
        }
        
        if let strength = medicine.strengthAmount {
            guard strength > 0 else {
                errorMessage = "Strength must be greater than zero."
                throw ValidationError(errorDescription: errorMessage)
            }
        }
        
        for ingredient in medicine.composition {
            let hasIngAmount = (ingredient.strengthAmount != nil)
            let hasIngUnit = !(ingredient.strengthUnit ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            if hasIngAmount != hasIngUnit {
                errorMessage = "Both strength value and unit must be provided together for all ingredients."
                throw ValidationError(errorDescription: errorMessage)
            }
            
            if let amount = ingredient.strengthAmount {
                guard amount > 0 else {
                    errorMessage = "Ingredient amounts must be greater than zero."
                    throw ValidationError(errorDescription: errorMessage)
                }
            }
        }
        
        if let stock = medicine.stock {
            let isQuantityZero = stock.quantity == 0
            let isUnitEmpty = stock.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            if isQuantityZero != isUnitEmpty {
                errorMessage = "Both stock quantity and unit must be provided together."
                throw ValidationError(errorDescription: errorMessage)
            }
            
            guard stock.quantity >= 0 else {
                errorMessage = "Stock quantity cannot be negative."
                throw ValidationError(errorDescription: errorMessage)
            }
        }
        
        if let dosage = medicine.dosage {
            if let quantity = dosage.dosageQuantity {
                guard quantity > 0 else {
                    errorMessage = "Dosage quantity must be greater than zero."
                    throw ValidationError(errorDescription: errorMessage)
                }
            }
            
            if let startDate = dosage.startDate, let endDate = dosage.endDate {
                guard startDate <= endDate else {
                    errorMessage = "Dosage start date must precede or equal the end date."
                    throw ValidationError(errorDescription: errorMessage)
                }
            }
        }
        
        // Remove empty text or empty list custom fields natively before validation
        medicine.customFields.removeAll { field in
            guard let type = field.definition?.dataType else { return false }
            switch type {
            case .text:
                let text = field.textValue ?? ""
                return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            case .list:
                return (field.listValue ?? []).isEmpty
            default:
                return false
            }
        }
        
        // Validate remaining custom fields
        for field in medicine.customFields {
            if let type = field.definition?.dataType {
                switch type {
                case .list:
                    if let list = field.listValue {
                        for item in list {
                            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                errorMessage = "Custom list fields cannot contain empty items."
                                throw ValidationError(errorDescription: errorMessage)
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        
        do {
            calculateStockEndDate()
            
            if let expiryDate = medicine.expiryDate {
                medicine.expiryDate = Calendar.current.startOfDay(for: expiryDate)
            }
            
            clearExistingNotifications(for: medicine)
            try NotificationManager.shared.scheduleInitialNotification(for: medicine)
            
            // Populate shopping list if within 7 days
            if ShoppingListPopulationHelper.shouldPopulate(stockEndDate: medicine.stock?.endDate, expiryDate: medicine.expiryDate) {
                medicine.isOnShoppingList = true
            } else {
                medicine.isOnShoppingList = false
            }
            
            try MedicineWriteManager.shared.save(medicine)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func calculateStockEndDate() -> Void {
        if let endDate = MedicineStockEndDateCalculator.calculate(
            stock: medicine.stock,
            dosage: medicine.dosage
        ) {
            medicine.stock?.endDate = endDate
        } else {
            medicine.stock?.endDate = .distantFuture
        }
    }
    
    func shareMedicine() async -> ShareContext? {
        do {
            let data = try await MedicineWriteManager.shared.fetchOrCreateShare(for: medicine)
            
            return ShareContext(share: data.0, container: data.1)
        } catch {
            print("Failed to fetch/create share: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func clearExistingNotifications(for medicine: Medicine) {
        guard let dosage = medicine.dosage else { return }
        
        // Reconstruct the identifiers for all possible reminders on this medicine
        let identifiersToCancel = dosage.reminderTimes.map { reminder in
            medicine.getNotificationIdentifier(for: reminder.id)
        }
        
        NotificationManager.shared.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
}
