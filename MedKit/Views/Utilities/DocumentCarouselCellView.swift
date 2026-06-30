//
//  DocumentCarouselCellView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct DocumentCarouselCellView: View {
    let document: Document
    
    @State private var renderedImage = Image(systemName: "photo")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(document.name)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding(5)
        }
        .frame(minWidth: 200, maxWidth: UIScreen.main.bounds.width / 2, minHeight: 200)
        .background(Color(uiColor: .systemGroupedBackground))
        .overlay(alignment: .bottom) {
            Text(document.documentExtension)
                .font(.subheadline)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding(5)
                .foregroundColor(.secondary)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadii: .init(bottomLeading: 12, bottomTrailing: 12)))
                .padding(5)
        }
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    DocumentCarouselCellView(document: Document(name: "Very Very Long Document Name", documentExtension: "pdf", documentData: Data(), documentType: .document))
}
