//
//  ContentView.swift
//  MedKit
//
//  Created by Ritwik Dev on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var story: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Story:")
                Text(story)
                Spacer()
                Button("Generate Story") {
                    Task {
                        story = try await GeminiModel.shared.generateStory()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
