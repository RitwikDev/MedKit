//
//  CalendarAgendaView.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI

struct CalendarAgendaView: View {
    @Environment(CalendarViewModel.self) private var viewModel
    
    private var events: [CalendarEvent] {
        viewModel.getEvents(forDate: viewModel.selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            let eventsCountText = events.count == 0 ? "" : "(\(events.count))"
            Text("Agenda \(eventsCountText)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
            
            if (events.isEmpty) {
                EmptyEntryView(text: "No Events")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                List(events) { event in
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(event.color)
                            .frame(width: 5, height: 50)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(event.title)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(event.date.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if event.eventType == .dosage {
                            Button {
                                viewModel.toggleDoseLog(for: event)
                            } label: {
                                Image(systemName: event.isTaken ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(event.isTaken ? .green : .gray)
                                    .padding(.trailing, 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    CalendarAgendaView()
        .environment(CalendarViewModel())
}
