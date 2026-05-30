//
//  MedicinesListView.swift
//  MedKit
//
//  Created by Ritwik Dev on 17/05/26.
//

import SwiftData
import SwiftUI

struct MedicinesListView: View {    
    @Query var medicines: [MedicineModel]
    
    @State private var medicineStackPath: [Medicine] = []
    
    var body: some View {
        NavigationStack(path: $medicineStackPath) {
            VStack {
                if (medicines.isEmpty) {
                    EmptyEntryView(text: "No Medicines Added")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                        .fontWeight(.black)
                } else {
                    List {
                        ForEach(medicines) { medicine in
                            NavigationLink(value: Medicine(from: medicine)) {
                                Text(medicine.name)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
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
                        Label("Add", systemImage: "ellipsis")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        medicineStackPath.append(.init())
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
    let container = PreviewContainerHelper.getMedicineContainer()
    return MedicinesListView().modelContainer(container)
}
