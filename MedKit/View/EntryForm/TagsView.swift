//
//  TagsView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsView: View {
    @Binding var tags: [String]
    
    var body: some View {
        VStack {
            ForEach($tags, id: \.self) { $tag in
                TextField(tag, text: $tag)
            }
        }
    }
}

#Preview {
    TagsView(tags: .constant(["Tag1", "Tag 2"]))
}
