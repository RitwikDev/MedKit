//
//  CustomFieldEntrySheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CustomFieldEntrySheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Custom Fields View")
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Label("Dismiss", systemImage: "xmark") }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button { dismiss() } label: { Label("Done", systemImage: "checkmark") }
                }
            }
            .navigationTitle("Custom Fields")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CustomFieldEntrySheetView()
}
