//
//  ContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "pill.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("MedKit")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
