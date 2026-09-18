//
//  ImageCarouselCellView.swift
//  MedKit
//
//  Created by Rishik Dev on 29/06/26.
//

import SwiftUI

struct ImageCarouselCellView: View {
    let uiImage: UIImage
    let deleteButtonAction: () -> Void
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .overlay(alignment: .bottomTrailing) {
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
                .padding(5)
            }
            .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    ImageCarouselCellView(uiImage: UIImage(systemName: "photo")!) { }
}
