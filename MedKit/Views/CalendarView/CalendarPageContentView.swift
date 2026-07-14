//
//  CalendarPageContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI

struct CalendarPageContentView: View {
    let date: Date
    var body: some View {
        VStack(spacing: 20) {
            CalendarMonthView(date: date)
            dashedLine
            CalendarAgendaView()
        }
        .padding()
    }
    
    private var dashedLine: some View {
        LineView()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .foregroundStyle(.separator)
            .frame(height: 2)
    }
}

#Preview {
    CalendarPageContentView(date: Date())
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(CalendarViewModel())
}
