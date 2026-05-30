//
//  EmptyEntryView.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import SwiftUI

struct EmptyEntryView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .foregroundStyle(.secondary)
            .italic()
    }
}

#Preview {
    EmptyEntryView(text: "Text")
}
