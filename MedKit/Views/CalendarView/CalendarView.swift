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
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMsg = viewModel.errorMessage {
                Text(errorMsg)
            }
        }
        .environment(viewModel)
    }
}

#Preview {
    return CalendarView()
        .environment(CalendarViewModel())
}
