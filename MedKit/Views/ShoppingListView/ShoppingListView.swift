//
//  ShoppingListView.swift
//  MedKit
//

import SwiftUI

struct ShoppingListView: View {
    @Environment(\.colorScheme) private var colourScheme
    @Environment(NavigationRouter.self) private var router
    @Environment(ShoppingListViewModel.self) private var viewModel
    
    @State private var showConfirmationDialog: Bool = false
    
    private let pub = NotificationCenter.default.publisher(for: NotificationManager.dataDidChangeNotification)
    
    private var backgroundColour: Color {
        if (colourScheme == .light) {
            return Color(uiColor: .secondarySystemBackground)
        } else {
            return Color(uiColor: .systemBackground)
        }
    }
    
    var body: some View {
        @Bindable var routerBindable = router
        NavigationStack(path: $routerBindable.path) {
            VStack {
                if (viewModel.items.isEmpty) {
                    ScrollView {
                        EmptyShoppingListView()
                    }
                    .defaultScrollAnchor(.center)
                } else {
                    List {
                        ForEach(viewModel.items) { medicine in
                            Button {
                                router.navigate(to: .medicineForm(for: medicine, isEditable: false))
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(medicine.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    VStack(alignment: .leading) {
                                        if let stock = medicine.stock {
                                            if stock.quantity > 0 {
                                                Text("Stock running low (\(Int(stock.quantity)) \(stock.unit) remaining)")
                                            } else {
                                                Text("Stockout")
                                            }
                                        }
                                        
                                        if let expiryDate = medicine.expiryDate {
                                            if Calendar.current.startOfDay(for: expiryDate) <= Calendar.current.startOfDay(for: .now) {
                                                Text("Expired on \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                            } else {
                                                Text("Expiring on \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                            }
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack {
                                            ForEach(Array(ShoppingListPopulationHelper.getReason(stockEndDate: medicine.stock?.endDate, expiryDate: medicine.expiryDate, stockQuantity: medicine.stock?.quantity).enumerated()), id: \.element) { index, reason in
                                                ChipItemView(
                                                    title: reason,
                                                    delay: Double(index) * 0.08,
                                                    tint: .red,
                                                    onSelect: {  }
                                                )
                                                .font(.footnote)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: performOnDelete)
                    }
                }
            }
            .background(backgroundColour)
            .refreshable {
                viewModel.fetchShoppingList()
            }
            .navigationTitle("Shopping List")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    clearShoppingListButton
                }
            }
            .onAppear {
                viewModel.fetchShoppingList()
            }
            .onReceive(pub) { _ in
                viewModel.fetchShoppingList()
            }
            .navigationDestination(for: NavigationPathEnum.self) { destination in
                destination.destination
            }
        }
    }
    
    private var clearShoppingListButton: some View {
        Button(role: .destructive) {
            showConfirmationDialog.toggle()
        } label: {
            Label("Clear Shopping List", systemImage: "trash")
                .labelStyle(.iconOnly)
        }
        .disabled(viewModel.items.isEmpty)
        .confirmationDialog(
            "Clear shopping list?",
            isPresented: $showConfirmationDialog,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                handleClearShoppingList()
            } label: {
                Label("Clear", systemImage: "trash")
            }
        } message: {
            Text("You cannot undo this action.")
        }
    }
    
    private func performOnDelete(indexSet: IndexSet) {
        withAnimation {
            viewModel.removeFromShoppingList(at: indexSet)
        }
    }
    
    private func handleClearShoppingList() {
        withAnimation {
            viewModel.clearShoppingList()
        }
    }
}

#Preview {
    ShoppingListView()
        .environment(NavigationRouter())
        .environment(ShoppingListViewModel())
}
