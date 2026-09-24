//
//  MedicineListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI
import NotificationCenter

struct MedicineListView: View {
    @Environment(\.colorScheme) private var colourScheme
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    @Environment(NavigationRouter.self) private var router
    @Environment(NotificationViewModel.self) private var notificationViewModel
    
    @State private var medicineViewModel: MedicineViewModel = .init()
    @State private var tabBarVisibility: Visibility = .automatic
    @State private var searchQuery: String = ""
    @State private var selectedTags: Set<UUID> = []
    @State private var showOnlyExpiringSoon: Bool = false
    @State private var sortSelection: MedicineListSortOptionsEnum = .nameAscending
    @State private var isControlsSheetOpen: Bool = false
        
    @State private var medicineToDelete: MedicineListItemModel?
    @State private var showDeleteAlert: Bool = false
    
    private var medicines: [MedicineListItemModel] {
        return medicineViewModel.medicines.filter { medicine in
            let tagIds = Set(medicine.tags.map { $0.id })
            
            let searchMatches = searchQuery.trimmedIsEmpty ||
            medicine.name.localizedCaseInsensitiveContains(searchQuery.trimmed)
            
            let hasTags = selectedTags.isEmpty || !selectedTags.intersection(tagIds).isEmpty
            
            let expirationMatches = !showOnlyExpiringSoon || medicine.isExpiringSoon
            
            return searchMatches && hasTags && expirationMatches
        }
    }
    
    private var backgroundColour: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
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
                    if (medicines.isEmpty) {
                        EmptyEntryView(text: "No medicines found")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                            .fontWeight(.black)
                    } else {
                        List {
                            ForEach(medicines) { medicine in
                                MedicineListItemView(
                                    medicine: medicine
                                )
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        medicineToDelete = medicine
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .environment(medicineViewModel)
            .onAppear {
                fetchData()
                requestNotificationAuthorisation()
            }
            .refreshable {
                fetchData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NotificationManager.dataDidChangeNotification)) { _ in
                fetchData()
            }
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    NewMedicineToolbarItemView()
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    MedicineListControlsView(isDrawerOpen: $isControlsSheetOpen)
                }
            }
            .onChange(of: router.path) { _, newValue in
                withAnimation(.bouncy(duration: 5)) {
                    tabBarVisibility = newValue.count == 0 ? .automatic : .hidden
                }
            }
            .onChange(of: sortSelection) { _, newValue in
                medicineViewModel.fetchAllMedicines(sortOn: sortSelection)
            }
            .navigationDestination(for: NavigationPathEnum.self) { route in
                route.destination
            }
            .navigationTitle("Medicines")
            .toolbar(tabBarVisibility, for: .tabBar)
            .alert("Delete Medicine", isPresented: $showDeleteAlert, presenting: medicineToDelete) { medicine in
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let index = medicineViewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
                        deleteMedicine(at: IndexSet(integer: index))
                    }
                }
            } message: { medicine in
                Text("Are you sure you want to delete \(medicine.name)?")
            }
            .background(backgroundColour)
        }
        .searchable(text: $searchQuery)
        .sheet(isPresented: $isControlsSheetOpen) {
            MedicineListControlsSheetView(
                isPresented: $isControlsSheetOpen,
                selectedTags: $selectedTags,
                showOnlyExpiringSoon: $showOnlyExpiringSoon,
                sortSelection: $sortSelection,
            )
            .interactiveDismissDisabled()
        }
    }
    
    private func deleteMedicine(at offset: IndexSet) {
        withAnimation {
            medicineViewModel.deleteMedicine(at: offset)
        }
    }
    
    private func fetchData() {
        medicineViewModel.fetchAllMedicines(sortOn: sortSelection)
        globalDataViewModel.fetchAllData()
    }
    
    private func requestNotificationAuthorisation() {
        notificationViewModel.requestAuthorisation()
    }
}

#Preview {
    MedicineListView()
        .environment(GlobalDataViewModel())
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
        .environment(NotificationViewModel(notificationManager: NotificationManager.shared))
}
