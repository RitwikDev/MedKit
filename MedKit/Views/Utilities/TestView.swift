//
//  TestView.swift
//  MedKit
//
//  Created by Rishik Dev on 24/05/26.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        List {
            ForEach(sampleTags) { tag in
                Text(tag.value)
                    .swipeActions(edge: .trailing) {
                        Text("Hi") 
                    }
            }
        }
    }
}

#Preview {
    TestView()
}
