//
//  SampleMedicinies.swift
//  MedKit
//
//  Created by Rishik Dev on 19/05/26.
//

import Foundation

// MARK: - Helper Extension for Clean Mock Dates
private extension Date {
    static func monthsAgo(_ count: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: -count, to: Date())
    }
    
    static func monthsFromNow(_ count: Int) -> Date? {
        Calendar.current.date(byAdding: .month, value: count, to: Date())
    }
    
    static func yearsFromNow(_ count: Int) -> Date? {
        Calendar.current.date(byAdding: .year, value: count, to: Date())
    }
}

// MARK: - 11 Sample Medicines Array
let sampleMedicines: [MedicineModel] = [
    MedicineModel(
        name: "Amoxicillin", quantity: 20,
        manufacturedDate: .monthsAgo(3), expiryDate: .monthsFromNow(9),
        strengthAmount: 500, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Ibuprofen", quantity: 50,
        manufacturedDate: .monthsAgo(6), expiryDate: .yearsFromNow(2),
        strengthAmount: 400, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Metformin HCl", quantity: 60,
        manufacturedDate: .monthsAgo(2), expiryDate: .monthsFromNow(18),
        strengthAmount: 850, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Atorvastatin", quantity: 30,
        manufacturedDate: .monthsAgo(1), expiryDate: .yearsFromNow(1),
        strengthAmount: 20, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Lisinopril", quantity: 90,
        manufacturedDate: .monthsAgo(5), expiryDate: .monthsFromNow(24),
        strengthAmount: 10, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Omeprazole", quantity: 28,
        manufacturedDate: .monthsAgo(4), expiryDate: .monthsFromNow(14),
        strengthAmount: 20, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Cetirizine", quantity: 15,
        manufacturedDate: .monthsAgo(8), expiryDate: .monthsFromNow(4),
        strengthAmount: 10, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Paracetamol Syrup", quantity: 1,
        manufacturedDate: .monthsAgo(2), expiryDate: .monthsFromNow(10),
        strengthAmount: 250, strengthUnit: "mg/5mL"
    ),
    MedicineModel(
        name: "Albuterol Inhaler", quantity: 2,
        manufacturedDate: .monthsAgo(12), expiryDate: .monthsFromNow(12),
        strengthAmount: 90, strengthUnit: "mcg/actuation"
    ),
    MedicineModel(
        name: "Prednisone", quantity: 10,
        manufacturedDate: .monthsAgo(1), expiryDate: .monthsFromNow(5),
        strengthAmount: 5, strengthUnit: "mg"
    ),
    MedicineModel(
        name: "Gabapentin", quantity: 100,
        manufacturedDate: .monthsAgo(7), expiryDate: .yearsFromNow(3),
        strengthAmount: 300, strengthUnit: "mg"
    )
]

let sampleComposition: [IngredientModel] = [
    IngredientModel(name: "Amoxicillin Trihydrate", strengthAmount: 500, strengthUnit: "mg"),
    IngredientModel(name: "Ibuprofen Sodium", strengthAmount: 400, strengthUnit: "mg"),
    IngredientModel(name: "Metformin Hydrochloride", strengthAmount: 850, strengthUnit: "mg"),
    IngredientModel(name: "Atorvastatin Calcium", strengthAmount: 20, strengthUnit: "mg"),
    IngredientModel(name: "Lisinopril Dihydrate", strengthAmount: 10, strengthUnit: "mg"),
    IngredientModel(name: "Omeprazole Magnesium", strengthAmount: 20, strengthUnit: "mg"),
    IngredientModel(name: "Cetirizine Dihydrochloride", strengthAmount: 10, strengthUnit: "mg"),
    IngredientModel(name: "Paracetamol", strengthAmount: 250, strengthUnit: "mg"),
    IngredientModel(name: "Albuterol Sulfate", strengthAmount: 90, strengthUnit: "mcg"),
    IngredientModel(name: "Prednisone Anhydrous", strengthAmount: 5, strengthUnit: "mg"),
    IngredientModel(name: "Gabapentin Crystalline", strengthAmount: 300, strengthUnit: "mg")
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
