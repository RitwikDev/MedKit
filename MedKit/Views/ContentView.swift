//
//  ContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var shoppingListViewModel = ShoppingListViewModel()
    @State private var selectedTab: Int = 0
    @State private var isProcessingShare: Bool = false
    
    @Environment(NavigationRouter.self) private var router
    
    let pub = NotificationCenter.default.publisher(for: NotificationManager.dataDidChangeNotification)
    let notificationTappedPub = NotificationCenter.default.publisher(for: NotificationManager.notificationTappedNotification)
    let shareStartedPub = NotificationCenter.default.publisher(for: NotificationManager.shareProcessingStarted)
    let shareFinishedPub = NotificationCenter.default.publisher(for: NotificationManager.shareProcessingFinished)

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MedicineListView()
                    .tabItem {
                        Label("Medicines", systemImage: "pills")
                    }
                    .tag(0)
                
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)
                    
                ShoppingListView()
                    .tabItem {
                        Label("Shopping List", systemImage: "cart")
                    }
                    .badge(shoppingListViewModel.items.count > 0 ? shoppingListViewModel.items.count : 0)
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .environment(shoppingListViewModel)
            .onAppear {
                shoppingListViewModel.fetchShoppingList()
            }
            .onReceive(pub) { _ in
                shoppingListViewModel.fetchShoppingList()
            }
            .onReceive(notificationTappedPub) { notification in
                if let medicineId = notification.userInfo?["medicineId"] as? UUID {
                    handleNotificationTap(medicineId: medicineId)
                }
            }
            .onReceive(shareStartedPub) { _ in
                withAnimation { isProcessingShare = true }
            }
            .onReceive(shareFinishedPub) { _ in
                withAnimation { isProcessingShare = false }
            }
            
            if isProcessingShare {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Processing...")
                        .padding(20)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }
    
    private func handleNotificationTap(medicineId: UUID) {
        selectedTab = 0
        
        Task {
            // Add a small delay to ensure TabView has switched to the MedicineListView
            // before attempting to push onto its NavigationStack
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            await MainActor.run {
                if let medicine = try? MedicineReadManager.shared.fetchById(medicineId) {
                    router.navigate(to: .medicineForm(for: medicine))
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(GlobalDataViewModel())
        .environment(ShoppingListViewModel())
        .environment(MedicineEditorViewModel())
        .environment(MedicineViewModel())
        .environment(NavigationRouter())
        .environment(NotificationViewModel(notificationManager: NotificationManager.shared))
}
