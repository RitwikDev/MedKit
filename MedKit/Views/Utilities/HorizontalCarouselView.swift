//
//  HorizontalCarouselView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct HorizontalCarouselView<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                content
            }
        }
    }
}

#Preview {
    HorizontalCarouselView {
        ForEach(0..<5) { item in
            Text(item, format: .number)
        }
    }
}
