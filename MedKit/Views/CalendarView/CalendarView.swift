//
//  CalendarView.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack {
            CalendarPageViewController(
                currentDate: $viewModel.currentMonth,
                viewModel: viewModel
            )
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .shadow(radius: 6)
        .onAppear(perform: viewModel.initialiseMedicines)
        .environment(viewModel)
    }
}

#Preview {
    return CalendarView()
        .environment(CalendarViewModel())
}
