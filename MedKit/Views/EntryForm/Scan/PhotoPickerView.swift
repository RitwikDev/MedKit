//
//  PhotoPickerView.swift
//  MedKit
//
//  Created by Rishik Dev on 15/06/26.
//

import PhotosUI
import SwiftUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedPhoto: Image?
    @Binding var selectedUIImage: UIImage?
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                if let selectedPhoto {
                    selectedPhoto
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(.circle)
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(.black.opacity(0.5))
                        .clipShape(.circle)
                }
            }
        }
        .onChange(of: selectedItem) {
            Task {
                await loadUIImage(from: selectedItem)
            }
        }
    }
    
    private func loadUIImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                
                await MainActor.run {
                    withAnimation {
                        self.selectedUIImage = uiImage
                    }
                }
            }
        } catch {
            print("Failed to load image data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PhotoPickerView(selectedUIImage: .constant(UIImage(systemName: "photo")))
}
