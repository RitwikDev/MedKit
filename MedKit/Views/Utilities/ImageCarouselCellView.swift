//
//  ImageCarouselCellView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct ImageCarouselCellView: View {
    let uiImage: UIImage
    
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    ImageCarouselCellView(uiImage: UIImage(systemName: "photo")!)
}
