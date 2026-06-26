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
    
    var body: some View {
        Section("Schedule") {
            if let schedule = schedule,
               schedule.repeatType != .never {
                Button(schedule.repeatType.rawValue) {
                    router.navigate(to: .medicineSchedule(for: schedule, medicineEditorViewModel: medicineEditorViewModel))
                }
                .foregroundStyle(.primary)
            } else {
                Button("Add Schedule") {
                    router.navigate(to: .medicineSchedule(for: schedule ?? .init(), medicineEditorViewModel: medicineEditorViewModel))
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                withAnimation {
                    medicineEditorViewModel.removeSchedule()
                }
            } label: {
                Label("Delete", systemImage: "bin")
            }
        }
    }
}

#Preview {
    Form {
        ScheduleSectionView(schedule: .constant(nil))
    }
    .environment(MedicineEditorViewModel())
    .environment(NavigationRouter())
}
