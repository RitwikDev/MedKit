//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicineListView: View {    
    @Query var medicines: [MedicineModel]

    @Environment(NavigationRouter.self) private var router
    private let medicineViewModel = MedicineViewModel()
    
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            VStack {
                if (medicines.isEmpty) {
                    EmptyMedicineListView()
                } else {
                    List {
                        ForEach(medicines) { medicine in
                            MedicineListItemView(
                                medicine: Medicine(from: medicine)
                            )
                        }
                    }
                }
            }
            .listStyle(.plain)
            .onAppear {
                medicineViewModel.medicine = .init()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NewMedicineToolbarItemView()
                }
            }
            .navigationDestination(for: NavigationPathEnum.self) { route in
                route.destination
            }
            .navigationTitle(Text("Medicines"))
        }
        .environment(medicineViewModel)
    }
}

#Preview {
    let container = PreviewContainerHelper.getMedicineContainer()
    
    return MedicineListView()
        .modelContainer(container)
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
}
