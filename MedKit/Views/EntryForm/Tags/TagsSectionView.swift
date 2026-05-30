//
//  TagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct TagsSectionView: View {
    @Binding var tags: [Tag]
    let buttonAction: () -> Void
    
    var body: some View {
        Section("Tags") {
            ForEach($tags) { $tag in
                Text(tag.value)
                    .foregroundStyle(.secondary)
            }
            .onDelete(perform: removeTags)
            
            Button("Add Tag", action: buttonAction)
        }
    }
}

#Preview {
    Form {
        TagsSectionView(
            tags: .constant([.init(value:"Tag 1"), .init(value: "Tag 2")]),
            buttonAction: { },
        )
    }
}
