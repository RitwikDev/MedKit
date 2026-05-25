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
    @State private var medicineStackPath: [Medicine] = []
    
    var body: some View {
        NavigationStack(path: $medicineStackPath) {
            List {
                ForEach(medicines) { medicine in
                    NavigationLink(value: Medicine(from: medicine)) {
                        Text(medicine.name)
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button {
                            medicineStackPath.append(.init())
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
            .navigationDestination(for: Medicine.self, destination: MedicineEntryFormView.init)
            .navigationTitle(Text("MedKit"))
        }
    }
}

#Preview {
    do {
        let container = try PreviewContainerHelper.getMedicineContainer()
        
        return MedicinesListView().modelContainer(container)
    } catch {
        fatalError("Failed")
    }
}
