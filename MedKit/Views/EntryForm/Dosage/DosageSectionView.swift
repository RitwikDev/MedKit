//
//  DosageSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 03/06/26.
//

import SwiftUI

struct DosageSectionView: View {
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(NavigationRouter.self) private var router
    @Binding var dosage: DosageModel?
    
    private var isDisabled: Bool {
        medicineEditorViewModel.medicine.stock == nil
    }
    
    var body: some View {
        Section(
            content: {
                if let dosage = dosage,
                   dosage.repeatType != .never {
                    Button(action: {
                        router.navigate(to: .medicineDosage(for: dosage, medicineEditorViewModel: medicineEditorViewModel))
                    }) {
                        dosageSummary(for: dosage)
                    }
                    .foregroundStyle(.primary)
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation {
                                medicineEditorViewModel.removeDosage()
                            }
                        } label: {
                            Label("Delete", systemImage: "bin")
                        }
                    }
                } else {
                    Button("Add Dosage") {
                        router.navigate(to: .medicineDosage(for: dosage ?? .init(), medicineEditorViewModel: medicineEditorViewModel))
                    }
                }
            },
            header: {
                Text("Dosage")
            },
            footer: {
                if (isDisabled) {
                    Text("Please add stock to add dosage.")
                }
            }
        )
        .disabled(isDisabled)
    }
    
    private func dosageSummary(for dosage: DosageModel) -> Text {
        guard let quantity = dosage.dosageQuantity, quantity > 0 else {
            return Text(dosage.repeatType.localizedName)
        }
        
        let quantityStr = quantity.formatted(.number)
        let unitStr = medicineEditorViewModel.medicine.stock?.unit ?? ""
        let timesCount = dosage.reminderTimes.count
        
        let repeatText: Text
        switch dosage.repeatType {
        case .selectDays:
            if dosage.selectedDays.isEmpty {
                repeatText = Text(dosage.repeatType.localizedName)
            } else {
                let joinedDays = dosage.selectedDays.map { String(localized: String.LocalizationValue($0.rawValue)) }.joined(separator: ", ")
                repeatText = Text("on \(joinedDays)")
            }
        case .custom:
            if dosage.selectedDates.isEmpty {
                repeatText = Text(dosage.repeatType.localizedName)
            } else {
                repeatText = Text("on \(dosage.selectedDates.count) selected dates")
            }
        default:
            repeatText = Text(dosage.repeatType.localizedName)
        }
        
        if timesCount <= 1 {
            return Text("\(quantityStr) \(unitStr) \(repeatText)")
        } else {
            return Text("\(quantityStr) \(unitStr), \(timesCount) times \(repeatText)")
        }
    }
}

#Preview {
    Form {
        DosageSectionView(dosage: .constant(nil))
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
