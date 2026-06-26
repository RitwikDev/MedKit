//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicineListView: View {    
    @Environment(NavigationRouter.self) private var router
    @State private var medicineListViewModel: MedicineListViewModel = .init()
    @State private var tabBarVisibility: Visibility = .automatic
    
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
            .environment(medicineListViewModel)
            .onAppear {
                medicineListViewModel.fetchAllMedicines()
            }
            .refreshable {
                medicineListViewModel.fetchAllMedicines()
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
            medicineListViewModel.deleteMedicine(at: offset)
        }
    }
}

#Preview {    
    MedicineListView()
        .environment(GlobalDataViewModel())
        .environment(MedicineListViewModel())
        .environment(NavigationRouter())
}
