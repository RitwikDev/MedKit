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

// MARK: - 11 Sample Medicines
let sampleMedicines: [MedicineModel] = [
    // 1. Amoxicillin (Antibiotic)
    MedicineModel(
        name: "Amoxicillin",
        quantity: 20.0,
        manufacturedDate: createDate(monthsFromNow: -3),
        expiryDate: createDate(monthsFromNow: 18),
        strength: StrengthModel(amount: 500, unit: "mg"),
        composition: [
            CompositionModel(name: "Amoxicillin Trihydrate", strength: StrengthModel(amount: 500, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Storage Condition", value: .text("Store below 25°C")),
            CustomFieldModel(label: "Prescription Required", value: .text("Yes"))
        ],
        tags: [.init(value: "Antibiotic"),
            .init(value: "Prescription Only"),
            .init(value: "Capsule")
        ]
    ),
    
    // 2. Paracetamol / Acetaminophen (Analgesic)
    MedicineModel(
        name: "Paracetamol",
        quantity: 50.0,
        manufacturedDate: createDate(monthsFromNow: -6),
        expiryDate: createDate(monthsFromNow: 24),
        strength: StrengthModel(amount: 500, unit: "mg"),
        composition: [
            CompositionModel(name: "Acetaminophen", strength: StrengthModel(amount: 500, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Storage Condition", value: .text("Store in a dry place")),
            CustomFieldModel(label: "Prescription Required", value: .text("No"))
        ],
        tags: [.init(value: "Pain Reliever"),
            .init(value: "Fever Reducer"),
            .init(value: "OTC")
        ]
    ),
    
    // 3. Ibuprofen (NSAID)
    MedicineModel(
        name: "Ibuprofen",
        quantity: 30.0,
        manufacturedDate: createDate(monthsFromNow: -2),
        expiryDate: createDate(monthsFromNow: 22),
        strength: StrengthModel(amount: 400, unit: "mg"),
        composition: [
            CompositionModel(name: "Ibuprofen", strength: StrengthModel(amount: 400, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Side Effects", value: .list(["Stomach upset", "Nausea", "Dizziness"]))
        ],
        tags: [.init(value: "NSAID"),
            .init(value: "Anti-inflammatory"),
            .init(value: "OTC")
        ]
    ),
    
    // 4. Atorvastatin (Cholesterol)
    MedicineModel(
        name: "Lipitor",
        quantity: 90.0,
        manufacturedDate: createDate(monthsFromNow: -5),
        expiryDate: createDate(monthsFromNow: 15),
        strength: StrengthModel(amount: 20, unit: "mg"),
        composition: [
            CompositionModel(name: "Atorvastatin Calcium", strength: StrengthModel(amount: 20, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Prescription Required", value: .text("Yes"))
        ],
        tags: [.init(value: "Statins"),
            .init(value: "Cholesterol"),
            .init(value: "Chronic")
        ]
    ),
    
    // 5. Metformin (Antidiabetic)
    MedicineModel(
        name: "Glucophage",
        quantity: 60.0,
        manufacturedDate: createDate(monthsFromNow: -4),
        expiryDate: createDate(monthsFromNow: 20),
        strength: StrengthModel(amount: 850, unit: "mg"),
        composition: [
            CompositionModel(name: "Metformin Hydrochloride", strength: StrengthModel(amount: 850, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Storage Condition", value: .text("Protect from light"))
        ],
        tags: [.init(value: "Diabetes"),
            .init(value: "Oral Hypoglycemic")
        ]
    ),
    
    // 6. Lisinopril (ACE Inhibitor for Blood Pressure)
    MedicineModel(
        name: "Lisinopril",
        quantity: 28.0,
        manufacturedDate: createDate(monthsFromNow: -1),
        expiryDate: createDate(monthsFromNow: 23),
        strength: StrengthModel(amount: 10, unit: "mg"),
        composition: [
            CompositionModel(name: "Lisinopril Dihydrate", strength: StrengthModel(amount: 10, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Side Effects", value: .list(["Dry cough", "Headache"]))
        ],
        tags: [.init(value: "Antihypertensive"),
            .init(value: "ACE Inhibitor"),
            .init(value: "Prescription Only")
        ]
    ),
    
    // 7. Cetirizine (Antihistamine)
    MedicineModel(
        name: "Zyrtec",
        quantity: 15.0,
        manufacturedDate: createDate(monthsFromNow: -8),
        expiryDate: createDate(monthsFromNow: 12),
        strength: StrengthModel(amount: 10, unit: "mg"),
        composition: [
            CompositionModel(name: "Cetirizine Hydrochloride", strength: StrengthModel(amount: 10, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Prescription Required", value: .text("No"))
        ],
        tags: [.init(value: "Antihistamine"),
            .init(value: "Allergy"),
            .init(value: "Non-Drowsy")
        ]
    ),
    
    // 8. Augmentin (Combination Antibiotic)
    MedicineModel(
        name: "Augmentin Duo",
        quantity: 14.0,
        manufacturedDate: createDate(monthsFromNow: -2),
        expiryDate: createDate(monthsFromNow: 10),
        strength: StrengthModel(amount: 625, unit: "mg"),
        composition: [
            CompositionModel(name: "Amoxicillin", strength: StrengthModel(amount: 500, unit: "mg")),
            CompositionModel(name: "Clavulanic Acid", strength: StrengthModel(amount: 125, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Storage Condition", value: .text("Store in airtight container"))
        ],
        tags: [.init(value: "Antibiotic"),
            .init(value: "Combination Drug"),
            .init(value: "Prescription Only")
        ]
    ),
    
    // 9. Salbutamol / Albuterol (Bronchodilator Inhaler)
    MedicineModel(
        name: "Ventolin Inhaler",
        quantity: 1.0,
        manufacturedDate: createDate(monthsFromNow: -7),
        expiryDate: createDate(monthsFromNow: 17),
        strength: StrengthModel(amount: 100, unit: "mcg/actuation"),
        composition: [
            CompositionModel(name: "Salbutamol Sulfate", strength: StrengthModel(amount: 100, unit: "mcg"))
        ],
        customFields: [
            CustomFieldModel(label: "Storage Condition", value: .text("Do not puncture or incinerate canister"))
        ],
        tags: [.init(value: "Asthma"),
            .init(value: "Bronchodilator"),
            .init(value: "Inhaler")
        ]
    ),
    
    // 10. Omeprazole (Antacid / PPI)
    MedicineModel(
        name: "Prilosec",
        quantity: 28.0,
        manufacturedDate: createDate(monthsFromNow: -3),
        expiryDate: createDate(monthsFromNow: 21),
        strength: StrengthModel(amount: 20, unit: "mg"),
        composition: [
            CompositionModel(name: "Omeprazole Magnesium", strength: StrengthModel(amount: 20, unit: "mg"))
        ],
        customFields: [
            CustomFieldModel(label: "Prescription Required", value: .text("No"))
        ],
        tags: [.init(value: "Antacid"),
            .init(value: "PPI"),
            .init(value: "Acid Reflux")
        ]
    ),
    
    // 11. Nux Vomica
    MedicineModel(
        name: "Nux Vomica",
        quantity: 2
    )
]

let sampleCompositions: [CompositionModel] = [
    CompositionModel(name: "Amoxicillin Trihydrate", strength: StrengthModel(amount: 500, unit: "mg")),
    CompositionModel(name: "Acetaminophen", strength: StrengthModel(amount: 500, unit: "mg")),
    CompositionModel(name: "Ibuprofen", strength: StrengthModel(amount: 400, unit: "mg")),
    CompositionModel(name: "Atorvastatin Calcium", strength: StrengthModel(amount: 20, unit: "mg")),
    CompositionModel(name: "Metformin Hydrochloride", strength: StrengthModel(amount: 850, unit: "mg")),
    CompositionModel(name: "Lisinopril Dihydrate", strength: StrengthModel(amount: 10, unit: "mg")),
    CompositionModel(name: "Cetirizine Hydrochloride", strength: StrengthModel(amount: 10, unit: "mg")),
    CompositionModel(name: "Amoxicillin", strength: StrengthModel(amount: 500, unit: "mg")),
    CompositionModel(name: "Clavulanic Acid", strength: StrengthModel(amount: 125, unit: "mg")),
    CompositionModel(name: "Salbutamol Sulfate", strength: StrengthModel(amount: 100, unit: "mcg")),
    CompositionModel(name: "Omeprazole Magnesium", strength: StrengthModel(amount: 20, unit: "mg"))
]

let sampleTags: [TagModel] = [
    .init(value: "ACE Inhibitor"),
    .init(value: "Acid Reflux"),
    .init(value: "Allergy"),
    .init(value: "Antacid"),
    .init(value: "Anti-inflammatory"),
    .init(value: "Antibiotic"),
    .init(value: "Antihistamine"),
    .init(value: "Antihypertensive"),
    .init(value: "Asthma"),
    .init(value: "Bronchodilator"),
    .init(value: "Capsule"),
    .init(value: "Cholesterol"),
    .init(value: "Chronic"),
    .init(value: "Combination Drug"),
    .init(value: "Diabetes"),
    .init(value: "Fever Reducer"),
    .init(value: "Inhaler"),
    .init(value: "Non-Drowsy"),
    .init(value: "NSAID"),
    .init(value: "Oral Hypoglycemic"),
    .init(value: "OTC"),
    .init(value: "Pain Reliever"),
    .init(value: "PPI"),
    .init(value: "Prescription Only"),
    .init(value: "Statins"),

]
