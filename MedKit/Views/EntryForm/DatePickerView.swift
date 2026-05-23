//
//  DatePickerView.swift
//  MedKit
//
//  Created by Rishik Dev on 21/05/26.
//

import SwiftUI

struct DatePickerView: View {
    let label: String
    @Binding var date: Date?
    
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        Group {
            if (date != nil) {
                HStack {
                    DatePicker(label,
                               selection: Binding(
                                get: { self.date ?? Date() },
                                set: { self.date = $0 }
                               ),
                               displayedComponents: .date)

                    
                    RoundedTintedButtonView(buttonAction: { showDeleteConfirmation.toggle() },
                                            title: "Delete \(label)?",
                                            systemImage: "xmark",
                                            tintColor: .red)
                }
            } else {
                Button("Add \(label)") {
                    date = Date()
                }
            }
        }
        .confirmationDialog("Delete \(label)?",
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button("Delete") {
                deleteDate()
            }
            Button("Cancel") { }
        }
    }
    
    private func deleteDate() {
        self.date = nil
    }
}

#Preview {
    DatePickerView(label: "Manufacture Date", date: .constant(Date()))
}
