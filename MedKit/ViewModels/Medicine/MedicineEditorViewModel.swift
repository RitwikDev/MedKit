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

struct ShareContext: Identifiable {
    let id = UUID()
    let share: CKShare
    let container: CKContainer
}

/// Powers the medicine creation and editing form.
/// Acts as a temporary scratchpad until the user taps "Save".
@Observable
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
        guard !medicine.name.isEmpty else {
            // TODO: - Add Data Validation Here...
            errorMessage = "Errors in medicine information."
            return
        }
        
        do {
            calculateStockEndDate()
            
            if let expiryDate = medicine.expiryDate {
                medicine.expiryDate = Calendar.current.startOfDay(for: expiryDate)
            }
            
            clearExistingNotifications(for: medicine)
            try NotificationManager.shared.scheduleInitialNotification(for: medicine)
            
            try MedicineWriteManager.shared.save(medicine)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func calculateStockEndDate() -> Void {
        if let endDate = MedicineStockEndDateCalculator.calculate(
            stock: medicine.stock,
            dosage: medicine.dosage,
        ) {
            medicine.stock?.endDate = endDate
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
