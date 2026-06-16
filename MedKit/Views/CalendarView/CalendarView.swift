//
//  CalendarView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDates: Set<DateComponents> = []
    var body: some View {
        NavigationStack {
            VStack {
                MultiDatePicker("Your Schedule", selection: $selectedDates)
            }
            .navigationTitle("Calendar")
        }
    }
}

#Preview {
    CalendarView()
}
