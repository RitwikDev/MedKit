//
//  MedicineViewModel.swift
//  MedKit
//
//  Created by Rishik Dev on 30/05/26.
//


import Foundation
import Observation

@Observable
class MedicineViewModel {
    // The source of truth for the form/view
    var medicine: Medicine

    init(medicine: Medicine = .init()) {
        self.medicine = medicine
    }
    
    func getMedicineFromCodableMedicineModel(cMedicineModel: CodableMedicineModel) {
        self.medicine = Medicine(
            name: cMedicineModel.name,
            manufacturedDate: cMedicineModel.manufacturedDate,
            expiryDate: cMedicineModel.expiryDate,
            strengthAmount: cMedicineModel.strengthAmount,
            strengthUnit: cMedicineModel.strengthUnit,
            composition: cMedicineModel.composition.map { Composition(name: $0.name, strengthAmount: $0.strengthAmount, strengthUnit: $0.strengthUnit) },
        )
    }

    // MARK: - Basic Info
    func updateName(_ name: String) {
        medicine.name = name.trimmed
    }

    func updateStrength(amount: Float?, unit: String?) {
        medicine.strengthAmount = amount
        medicine.strengthUnit = unit?.trimmed
    }

    func updateQuantity(_ quantity: Float) {
        medicine.quantity = quantity
    }

    // MARK: - Composition Management
    func upsertComposition(_ composition: Composition) {
        if let index = medicine.composition.firstIndex(where: { $0.id == composition.id }) {
            // Update existing
            medicine.composition[index] = composition
        } else {
            // Add new
            medicine.composition.append(composition)
        }
    }
    
    func addCompositions(_ compositions: [Composition]) {
        for (index, composition) in compositions.enumerated() {
            let isPresent = medicine.composition.contains(where: { $0.equalsName(composition) })
            if (isPresent) {
                medicine.composition.remove(at: index)
            }
            
            medicine.composition.append(composition)
        }
    }

    func removeComposition(at offsets: IndexSet) {
        medicine.composition.remove(atOffsets: offsets)
    }

    func removeComposition(_ composition: Composition) {
        medicine.composition.removeAll { $0.id == composition.id }
    }
    
    func removeSchedule() {
        medicine.schedule = nil
    }

    // MARK: - Tag Management
    func addTag(_ tag: Tag) {
        let trimmedValue = tag.value.trimmed
        guard !trimmedValue.isEmpty else { return }
        
        // Prevent duplicates in the UI state
        if !medicine.tags.contains(where: { $0.value.lowercased() == trimmedValue.lowercased() }) {
            var newTag = tag
            newTag.value = trimmedValue
            medicine.tags.append(newTag)
        }
    }

    func removeTag(_ tag: Tag) {
        medicine.tags.removeAll { $0.id == tag.id }
    }
    
    func removeTags(at offsets: IndexSet) {
        medicine.tags.remove(atOffsets: offsets)
    }

    // MARK: - Dates
    func updateDates(manufactured: Date?, expiry: Date?) {
        medicine.manufacturedDate = manufactured
        medicine.expiryDate = expiry
    }
}
