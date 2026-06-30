//
//  DocumentPreviewSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct DocumentPreviewSheetView: View {
    let document: Document
    let buttonAction: () -> Void
    
    var body: some View {
        NavigationStack {
            DocumentPreviewView(document: document)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: buttonAction)
                    }
                }
                .navigationTitle(document.name)
                .navigationBarTitleDisplayMode(.inline)
                
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    DocumentPreviewSheetView(document: .init(name: "Document 1", documentExtension: ".pdf", documentData: Data(), documentType: .document)) { }
}
