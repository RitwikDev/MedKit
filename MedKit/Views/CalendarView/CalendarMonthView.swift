//
//  CalendarMonthView.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI

struct CalendarMonthView: View {
    @Environment(CalendarViewModel.self) private var viewModel
    
    let date: Date
    
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        HStack {
            CircularButtonView(
                title: "Previous month",
                systemImage: "chevron.left",
                tintColor: .blue
            ) {
                viewModel.changeMonth(by: -1)
            }
            
            Spacer()
            
            Text(viewModel.monthYearHeaderString(for: date))
                .font(.title3.bold())
            
            Spacer()
            
            CircularButtonView(
                title: "Next month",
                systemImage: "chevron.right",
                tintColor: .blue
            ) {
                viewModel.changeMonth(by: 1)
            }
        }
        
        HStack {
            ForEach(daysOfWeek.indices, id: \.self) { i in
                Text(daysOfWeek[i])
                    .font(.caption.bold())
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
            }
        }
        
        LazyVGrid(columns: columns, spacing: 12) {
            // Pass the local date here
            ForEach(viewModel.daysForMonth(of: date)) { day in
                if let dayDate = day.date {
                    let isSelected = Calendar.current.isDate(
                        dayDate,
                        equalTo: viewModel.selectedDate,
                        toGranularity: .day
                    )
                    let dayEvents = viewModel.getEvents(forDate: dayDate)
                    
                    VStack {
                        Text("\(day.dayNumber)")
                            .frame(minWidth: 30, minHeight: 30)
                            .background(isSelected ? .blue : .clear)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(.circle)
                        
                        HStack {
                            if (!dayEvents.isEmpty) {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .frame(height: 5)
                    }
                    .onTapGesture {
                        viewModel.selectedDate = dayDate
                    }
                } else {
                    Color.clear.frame(minWidth: 30, minHeight: 30)
                }
            }
        }
    }
}

#Preview {
    CalendarMonthView(date: Date())
        .environment(CalendarViewModel())
}
