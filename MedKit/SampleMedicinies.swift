//
//  SampleMedicinies.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import Foundation

// MARK: - Date Helper for Realism
func createDate(monthsFromNow: Int) -> Date {
    return Calendar.current.date(byAdding: .month, value: monthsFromNow, to: Date()) ?? Date()
}

// MARK: - Mock Custom Field IDs
// Simulating predefined custom fields (e.g., Storage condition, Brand Owner, Prescription required)
let storageConditionFieldId = UUID()
let prescriptionRequiredFieldId = UUID()
let sideEffectsFieldId = UUID()

// MARK: - 10 Sample Medicines
let sampleMedicines: [MedicineModel] = [
    // 1. Amoxicillin (Antibiotic)
    MedicineModel(
        name: "Amoxicillin",
        quantity: 20.0,
        manufacturedDate: createDate(monthsFromNow: -3),
        expiryDate: createDate(monthsFromNow: 18),
        strength: StrengthModel(amount: 500, unit: "mg"),
        compositions: [
            CompositionModel(name: "Amoxicillin Trihydrate", strength: StrengthModel(amount: 500, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: storageConditionFieldId, value: .text("Store below 25°C")),
            MedicineCustomFieldModel(customFieldId: prescriptionRequiredFieldId, value: .text("Yes"))
        ],
        tags: ["Antibiotic", "Prescription Only", "Capsule"]
    ),
    
    // 2. Paracetamol / Acetaminophen (Analgesic)
    MedicineModel(
        name: "Paracetamol",
        quantity: 50.0,
        manufacturedDate: createDate(monthsFromNow: -6),
        expiryDate: createDate(monthsFromNow: 24),
        strength: StrengthModel(amount: 500, unit: "mg"),
        compositions: [
            CompositionModel(name: "Acetaminophen", strength: StrengthModel(amount: 500, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: storageConditionFieldId, value: .text("Store in a dry place")),
            MedicineCustomFieldModel(customFieldId: prescriptionRequiredFieldId, value: .text("No"))
        ],
        tags: ["Pain Reliever", "Fever Reducer", "OTC"]
    ),
    
    // 3. Ibuprofen (NSAID)
    MedicineModel(
        name: "Ibuprofen",
        quantity: 30.0,
        manufacturedDate: createDate(monthsFromNow: -2),
        expiryDate: createDate(monthsFromNow: 22),
        strength: StrengthModel(amount: 400, unit: "mg"),
        compositions: [
            CompositionModel(name: "Ibuprofen", strength: StrengthModel(amount: 400, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: sideEffectsFieldId, value: .list(["Stomach upset", "Nausea", "Dizziness"]))
        ],
        tags: ["NSAID", "Anti-inflammatory", "OTC"]
    ),
    
    // 4. Atorvastatin (Cholesterol)
    MedicineModel(
        name: "Lipitor",
        quantity: 90.0,
        manufacturedDate: createDate(monthsFromNow: -5),
        expiryDate: createDate(monthsFromNow: 15),
        strength: StrengthModel(amount: 20, unit: "mg"),
        compositions: [
            CompositionModel(name: "Atorvastatin Calcium", strength: StrengthModel(amount: 20, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: prescriptionRequiredFieldId, value: .text("Yes"))
        ],
        tags: ["Statins", "Cholesterol", "Chronic"]
    ),
    
    // 5. Metformin (Antidiabetic)
    MedicineModel(
        name: "Glucophage",
        quantity: 60.0,
        manufacturedDate: createDate(monthsFromNow: -4),
        expiryDate: createDate(monthsFromNow: 20),
        strength: StrengthModel(amount: 850, unit: "mg"),
        compositions: [
            CompositionModel(name: "Metformin Hydrochloride", strength: StrengthModel(amount: 850, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: storageConditionFieldId, value: .text("Protect from light"))
        ],
        tags: ["Diabetes", "Oral Hypoglycemic"]
    ),
    
    // 6. Lisinopril (ACE Inhibitor for Blood Pressure)
    MedicineModel(
        name: "Lisinopril",
        quantity: 28.0,
        manufacturedDate: createDate(monthsFromNow: -1),
        expiryDate: createDate(monthsFromNow: 23),
        strength: StrengthModel(amount: 10, unit: "mg"),
        compositions: [
            CompositionModel(name: "Lisinopril Dihydrate", strength: StrengthModel(amount: 10, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: sideEffectsFieldId, value: .list(["Dry cough", "Headache"]))
        ],
        tags: ["Antihypertensive", "ACE Inhibitor", "Prescription Only"]
    ),
    
    // 7. Cetirizine (Antihistamine)
    MedicineModel(
        name: "Zyrtec",
        quantity: 15.0,
        manufacturedDate: createDate(monthsFromNow: -8),
        expiryDate: createDate(monthsFromNow: 12),
        strength: StrengthModel(amount: 10, unit: "mg"),
        compositions: [
            CompositionModel(name: "Cetirizine Hydrochloride", strength: StrengthModel(amount: 10, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: prescriptionRequiredFieldId, value: .text("No"))
        ],
        tags: ["Antihistamine", "Allergy", "Non-Drowsy"]
    ),
    
    // 8. Augmentin (Combination Antibiotic)
    MedicineModel(
        name: "Augmentin Duo",
        quantity: 14.0,
        manufacturedDate: createDate(monthsFromNow: -2),
        expiryDate: createDate(monthsFromNow: 10),
        strength: StrengthModel(amount: 625, unit: "mg"),
        compositions: [
            CompositionModel(name: "Amoxicillin", strength: StrengthModel(amount: 500, unit: "mg")),
            CompositionModel(name: "Clavulanic Acid", strength: StrengthModel(amount: 125, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: storageConditionFieldId, value: .text("Store in airtight container"))
        ],
        tags: ["Antibiotic", "Combination Drug", "Prescription Only"]
    ),
    
    // 9. Salbutamol / Albuterol (Bronchodilator Inhaler)
    MedicineModel(
        name: "Ventolin Inhaler",
        quantity: 1.0,
        manufacturedDate: createDate(monthsFromNow: -7),
        expiryDate: createDate(monthsFromNow: 17),
        strength: StrengthModel(amount: 100, unit: "mcg/actuation"),
        compositions: [
            CompositionModel(name: "Salbutamol Sulfate", strength: StrengthModel(amount: 100, unit: "mcg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: storageConditionFieldId, value: .text("Do not puncture or incinerate canister"))
        ],
        tags: ["Asthma", "Bronchodilator", "Inhaler"]
    ),
    
    // 10. Omeprazole (Antacid / PPI)
    MedicineModel(
        name: "Prilosec",
        quantity: 28.0,
        manufacturedDate: createDate(monthsFromNow: -3),
        expiryDate: createDate(monthsFromNow: 21),
        strength: StrengthModel(amount: 20, unit: "mg"),
        compositions: [
            CompositionModel(name: "Omeprazole Magnesium", strength: StrengthModel(amount: 20, unit: "mg"))
        ],
        customFields: [
            MedicineCustomFieldModel(customFieldId: prescriptionRequiredFieldId, value: .text("No"))
        ],
        tags: ["Antacid", "PPI", "Acid Reflux"]
    )
]
