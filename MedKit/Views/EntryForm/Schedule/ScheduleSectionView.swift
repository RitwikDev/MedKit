//
//  ScheduleSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 03/06/26.
//

import SwiftUI

struct ScheduleSectionView: View {
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(NavigationRouter.self) private var router
    @Binding var schedule: Schedule?
    
    private var isDisabled: Bool {
        medicineEditorViewModel.medicine.stock == nil
    }
    
    var body: some View {
        Section(
            content: {
                if let schedule = schedule,
                   schedule.repeatType != .never {
                    Button(schedule.repeatType.rawValue) {
                        router.navigate(to: .medicineSchedule(for: schedule, medicineEditorViewModel: medicineEditorViewModel))
                    }
                    .foregroundStyle(.primary)
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation {
                                medicineEditorViewModel.removeSchedule()
                            }
                        } label: {
                            Label("Delete", systemImage: "bin")
                        }
                    }
                } else {
                    Button("Add Schedule") {
                        router.navigate(to: .medicineSchedule(for: schedule ?? .init(), medicineEditorViewModel: medicineEditorViewModel))
                    }
                }
            },
            header: {
                Text("Schedule")
            },
            footer: {
                if (isDisabled) {
                    Text("Stock is required for adding schedule")
                }
            }
        )
        .disabled(isDisabled)
    }
}

#Preview {
    Form {
        ScheduleSectionView(schedule: .constant(nil))
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
