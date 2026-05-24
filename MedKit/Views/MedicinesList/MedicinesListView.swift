//
//  MedicinesListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicinesListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query var medicines: [MedicineModel]
    
//    @State private var medicines = sampleMedicines
    @State private var medicineStackPath: [MedicineModel] = []
    
    var body: some View {
        NavigationStack(path: $medicineStackPath) {
            List {
                ForEach(medicines) { medicine in
                    NavigationLink(value: medicine) {
                        Text(medicine.name)
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button {
                            let newMedicine: MedicineModel = .init()
                            modelContext.insert(newMedicine)
                            medicineStackPath.append(newMedicine)
                        } label: {
                            Label("Manual", systemImage: "pencil")
                        }
                        
                        Button {
                            medicineStackPath.append(.init())
                        } label: {
                            Label("Scan", systemImage: "camera.viewfinder")
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: MedicineModel.self, destination: MedicineEntryFormView.init)
            .navigationTitle(Text("MedKit"))
        }
    }
}

#Preview {
    do {
        let configuration = ModelConfiguration (isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MedicineModel.self, configurations: configuration)
        
        return MedicinesListView()
            .modelContainer(container)
    } catch {
        fatalError("Failed")
    }
}
