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
                    Button(dosage.repeatType.localizedName) {
                        router.navigate(to: .medicineDosage(for: dosage, medicineEditorViewModel: medicineEditorViewModel))
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
}

#Preview {
    Form {
        DosageSectionView(dosage: .constant(nil))
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
