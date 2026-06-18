//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicineListView: View {    
    @Query(sort: \MedicineModel.name) var medicines: [MedicineModel]

    @Environment(NavigationRouter.self) private var router    
    @State private var medicineViewModel = MedicineViewModel()
    
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
            .onChange(of: router.path) { _, newValue in
                if (newValue.count == 0) {
                    medicineViewModel.medicine = .init()
                }
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
    return MedicineListView()
        .modelContainer(PreviewData.container)
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
}
