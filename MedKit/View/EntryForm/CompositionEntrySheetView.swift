//
//  CompositionEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionEntrySheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Composition View")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Label("Dismiss", systemImage: "xmark") }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Label("Done", systemImage: "checkmark") }
                }
            }
            .navigationTitle("Composition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        CompositionEntrySheetView()
    }
}
