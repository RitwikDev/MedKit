//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicineListView: View {    
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    @Environment(MedicineListViewModel.self) private var medicineListViewModel
    @Environment(NavigationRouter.self) private var router
    
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            VStack {
                if (medicineListViewModel.medicines.isEmpty) {
                    ScrollView {
                        EmptyMedicineListView()
                    }
                    .defaultScrollAnchor(.center)
                } else {
                    List {
                        ForEach(medicineListViewModel.medicines) { medicine in
                            MedicineListItemView(
                                medicine: medicine
                            )
                        }
                        .onDelete(perform: deleteMedicine)
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                medicineListViewModel.fetchAllMedicines()
            }
            .onChange(of: router.path) { _, newValue in
                if (newValue.count == 0) {
                    medicineEditorViewModel.medicine = .init()
                }
            }
            .refreshable {
                medicineListViewModel.fetchAllMedicines()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NewMedicineToolbarItemView()
                }
            }
            .navigationDestination(for: NavigationPathEnum.self) { route in
                route.destination
            }
            .navigationTitle("Medicines")
        }
    }
    
    private func deleteMedicine(at offset: IndexSet) {
        withAnimation {
            medicineListViewModel.deleteMedicine(at: offset)
        }
    }
}

#Preview {    
    MedicineListView()
        .environment(GlobalDataViewModel())
        .environment(MedicineEditorViewModel())
        .environment(MedicineListViewModel())
        .environment(NavigationRouter())
}
