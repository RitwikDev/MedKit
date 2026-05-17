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

    @Query var medicines: [MedicineModel]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(medicines) { medicine in
                    Text(medicine.name)
                }
            }
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
