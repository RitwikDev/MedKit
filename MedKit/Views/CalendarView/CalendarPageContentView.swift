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
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let layout = isLandscape ? AnyLayout(HStackLayout(spacing: 20)) : AnyLayout(VStackLayout(spacing: 20))
            
            layout {
                CalendarMonthView(date: date)
                
                dashedLine(isLandscape: isLandscape)
                
                CalendarAgendaView()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    private func dashedLine(isLandscape: Bool) -> some View {
        LineView(isVertical: isLandscape)
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
            .foregroundStyle(.separator)
            .frame(width: isLandscape ? 2 : nil, height: isLandscape ? nil : 2)
    }
}

#Preview {
    CalendarPageContentView(date: Date())
        .padding()
        .background(Color(.systemGroupedBackground))
        .environment(CalendarViewModel())
}
