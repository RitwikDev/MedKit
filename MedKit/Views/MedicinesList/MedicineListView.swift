//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicineListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Environment(NavigationRouter.self) private var router
    @State private var medicineViewModel: MedicineViewModel = .init()
    @State private var tabBarVisibility: Visibility = .automatic
    
    var body: some View {
        @Bindable var router = router
        
        NavigationStack(path: $router.path) {
            VStack {
                if (medicineViewModel.medicines.isEmpty) {
                    ScrollView {
                        EmptyMedicineListView()
                    }
                    .defaultScrollAnchor(.center)
                } else {
                    List {
                        ForEach(medicineViewModel.medicines) { medicine in
                            MedicineListItemView(
                                medicine: medicine
                            )
                        }
                        .onDelete(perform: deleteMedicine)
                    }
                    .listStyle(.plain)
                }
            }
            .environment(medicineViewModel)
            .onAppear(perform: fetchData)
            .refreshable {
                fetchData()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    NewMedicineToolbarItemView()
                }
            }
            .onChange(of: router.path) { _, newValue in
                withAnimation(.bouncy(duration: 5)) {
                    tabBarVisibility = newValue.count == 0 ? .automatic : .hidden
                }
            }
            .navigationDestination(for: NavigationPathEnum.self) { route in
                route.destination
            }
            .navigationTitle("Medicines")
            .toolbar(tabBarVisibility, for: .tabBar)
        }
    }
    
    private func deleteMedicine(at offset: IndexSet) {
        withAnimation {
            medicineViewModel.deleteMedicine(at: offset)
        }
    }
    
    private func fetchData() {
        medicineViewModel.fetchAllMedicines()
        globalDataViewModel.fetchAllData()
    }
}

#Preview {    
    MedicineListView()
        .environment(GlobalDataViewModel())
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
}
