//
//  ImagePreviewSheetView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct ImagePreviewSheetView: View {
    let uiImage: UIImage
    let buttonAction: () -> Void
    
    var body: some View {
        NavigationStack {
            ZoomablePhotoView(photo: uiImage)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: buttonAction)
                    }
                }
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    ImagePreviewSheetView(uiImage: UIImage(systemName: "photo")!) { }
}
