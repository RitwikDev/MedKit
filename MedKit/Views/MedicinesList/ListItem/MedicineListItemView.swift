//
//  MedicineListItemView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import CloudKit
import SwiftUI

private struct ShareContext: Identifiable {
    let id = UUID()
    let share: CKShare
    let container: CKContainer
}

struct MedicineListItemView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineViewModel.self) private var medicineViewModel
    
    let medicine: MedicineListItemModel
    
    @State private var shareContext: ShareContext? = nil
    @State private var shareData: (share: CKShare, container: CKContainer)? = nil
    
    var body: some View {
        Button {
            if let completeMedicine = medicineViewModel.getById(medicine.id) {
                router.navigate(to: .medicineForm(for: completeMedicine))
            }
        } label: {
            buttonLabel
        }
        .contextMenu {
            Button {
                prepareShare()
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .tint(.primary)
        .sheet(item: $shareContext) { context in
            CloudSharingView(share: context.share, container: context.container)
                .ignoresSafeArea()
        }
    }
    
    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(medicine.name)
                    .font(.headline)
                
                Spacer()
                
                MedicineListItemIconsView(medicine: medicine)
            }
            
            if let strengthAmount = medicine.strengthAmount,
                let strengthUnit = medicine.strengthUnit {
                Text("\(String(format: "%.3f", strengthAmount)) \(strengthUnit)")
            }
            
            MedicineListItemExpiryView(medicine: medicine)
            
            if let stock = medicine.stock {
                if (stock.unit.trimmed == "") {
                    EmptyView()
                } else {
                    MedicineListItemStockView(
                        medicineId: medicine.id,
                        stock: stock,
                        dosage: medicine.dosage,
                    )
                }
            }
            
            if (!medicine.tags.isEmpty) {
                MedicineListItemTagsView(medicine: medicine)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.subheadline)
        .padding()
        .roundedRectBackground(colour: Color(uiColor: .systemBackground))
        .shadow(color: .gray, radius: 10)
        .padding(.vertical, 5)
    }
    
    private func prepareShare() {
//        Task {
//            do {
//                // Call the newly updated manager function
//                let data = try await MedicineWriteManager.shared.fetchOrCreateShare(for: medicine)
//                
//                await MainActor.run {
//                    // Inject the struct. This safely triggers the .sheet(item:)
//                    self.shareContext = ShareContext(share: data.0, container: data.1)
//                }
//            } catch {
//                print("Failed to fetch/create share: \(error.localizedDescription)")
//            }
//        }
    }
}

#Preview {
    MedicineListItemView(
        medicine: MedicineListItemModel(
            id: UUID(),
            name: "Medicine Name",
            strengthAmount: 10,
            strengthUnit: "mg",
            stock: nil,
            dosage: nil,
            expiryDate: .now,
            tags: [],
        )
    )
    .environment(NavigationRouter())
    .environment(MedicineViewModel())
}
