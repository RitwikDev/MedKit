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
        VStack {
            Text("Agenda")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if events.isEmpty {
                EmptyEntryView(text: "No Events")
                    .frame(maxHeight: .infinity, alignment: .center)
            } else {
                List(events) { event in
                    Text(event.title)
                        .listRowInsets(EdgeInsets())
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
