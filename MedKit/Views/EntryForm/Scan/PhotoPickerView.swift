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
    @State private var errorMessage: String? = nil
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
        .alert(
            "Error",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            if let msg = errorMessage {
                Text(msg)
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
            await MainActor.run {
                self.errorMessage = AppError.scanImageProcessingFailed.errorDescription
            }
        }
    }
}

#Preview {
    PhotoPickerView(selectedUIImage: .constant(UIImage(systemName: "photo")))
}
