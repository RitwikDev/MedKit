//
//  DatePickerView.swift
//  MedKit
//
//  Created by Rishik Dev on 21/05/26.
//

import SwiftUI

struct DatePickerView: View {
    let label: LocalizedStringKey
    @Binding var date: Date?
    
    @State private var showDeleteConfirmation: Bool = false
    
    var body: some View {
        Group {
            if (date != nil) {
                DatePicker(
                    label,
                    selection: Binding(
                        get: { self.date ?? Date() },
                        set: { self.date = $0 }
                    ),
                    displayedComponents: .date
                )
                .swipeActions {
                    Button(role: .destructive) {
                        withAnimation {
                            date = nil
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } else {
                Button(label) {
                    addDate()
                }
            }
        }
    }
    
    private func addDate() {
        withAnimation {
            date = Date()
        }
    }
    
    private func deleteDate() {
        withAnimation {
            self.date = nil
        }
    }
}

#Preview {
    Form {
        DatePickerView(label: "Manufacture Date", date: .constant(Date()))
    }
}
