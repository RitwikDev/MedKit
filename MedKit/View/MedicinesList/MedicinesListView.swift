//
//  MedicinesListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicinesListView: View {
    @Environment(\.modelContext) var modelContext

//    @Query var medicines: [MedicineModel]
    @State private var medicines = sampleMedicines
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
                    Button {
                        medicineStackPath.append(.init())
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: MedicineModel.self) { medicine in
                MedicineEntryFormView(medicine: medicine)
            }
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(Text("MedKit"))
        }
    }
}

#Preview {
    do {
        let configuraion = ModelConfiguration (isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: MedicineModel.self, configurations: configuraion)
        
        return MedicinesListView()
            .modelContainer(container)
    } catch {
        fatalError("Failed")
    }
}
