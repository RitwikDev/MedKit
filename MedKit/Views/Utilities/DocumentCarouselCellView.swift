//
//  DocumentCarouselCellView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct DocumentCarouselCellView: View {
    let document: Document
    let deleteButtonAction: () -> Void
    
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
            bottomOverlay
        }
        .clipShape(.rect(cornerRadius: 12))
    }
    
    private var bottomOverlay: some View {
        HStack {
            Text(document.documentExtension)
            
            Spacer()
            
            Button {
                withAnimation {
                    deleteButtonAction()
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.red)
                    }
            }
        }
        .font(.subheadline)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity)
        .padding(5)
        .foregroundColor(.secondary)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
        .padding(5)
    }
}

#Preview {
    DocumentCarouselCellView(
        document: Document(name: "Very Very Long Document Name", documentExtension: "pdf", documentData: Data(), documentType: .document)) {
            
        }
}
