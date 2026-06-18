//
//  CameraAndPhotoPickerView.swift
//  MedKit
//
//  Created by Rishik Dev on 26/05/26.
//

import SwiftUI
#if targetEnvironment(simulator)
import SimulatorCameraService
#else
import DeviceCameraService
#endif

struct CameraAndPhotoPickerView: View {
    @State private var camera = CameraService()
    @State private var errorMessage: String?
    @State private var lastZoomFactor: CGFloat = 1.0
    @State private var focusLocation: CGPoint = .zero
    @State private var showFocusBox: Bool = false
    @State private var focusBoxScale: CGFloat = 1.5
    @State private var selectedPhoto: UIImage?
    
    private var displayZoomString: String {
        let userZoom = camera.currentZoomFactor / camera.baseZoomFactor
        let roundedZoom = round(userZoom * 10) / 10.0
        
        if roundedZoom.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0fx", roundedZoom)
        } else {
            return String(format: "%.1fx", roundedZoom)
        }
    }
    
    var body: some View {
        ZStack {
            if (errorMessage != nil) {
                errorView
            } else {
                if let capturedImage = camera.capturedImage {
                    PhotoPreviewView(cameraService: camera, photo: capturedImage) {
                        withAnimation {
                            Task {
                                await setupCamera()
                            }
                            camera.capturedImage = nil
                        }
                    }
                } else if let selectedPhoto = selectedPhoto {
                    PhotoPreviewView(cameraService: camera, photo: selectedPhoto) {
                        withAnimation {
                            Task {
                                await setupCamera()
                            }
                            self.selectedPhoto = nil
                        }
                    }
                } else {
                    cameraFeedLayer
                    
                    if (showFocusBox) {
                        focusIndicatorLayer
                    }
                    
                    cameraControlsLayer
                }
            }
        }
        .task {
            await setupCamera()
        }
        .onDisappear {
            camera.stopCamera()
        }
        .toolbar(.hidden, for: .tabBar)
        .background(.black)
    }
}

// MARK: - View Components
extension CameraAndPhotoPickerView {
    private var errorView: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
            .imageScale(.large)
            
            Text(errorMessage ?? "")
                .fontWeight(.bold)
        }
        .foregroundStyle(.red)
    }
    
    private var cameraFeedLayer: some View {
        CameraPreview(
            service: camera,
            executeHardwareFocus: { cameraPoint in
                try? camera.focus(at: cameraPoint)
            },
            updateUIFocusBox: { viewPoint in
                handleTapToFocus(viewPoint: viewPoint)
            }
        )
        .ignoresSafeArea()
        .gesture(
            MagnifyGesture()
                .onChanged { value in
                    let delta = value.magnification / lastZoomFactor
                    try? camera.zoom(with: delta)
                    lastZoomFactor = value.magnification
                }
                .onEnded { _ in lastZoomFactor = 1.0 }
        )
    }
    
    private var focusIndicatorLayer: some View {
        FocusBoxView(focusBoxScale: focusBoxScale, focusLocation: focusLocation)
    }
    
    private var cameraControlsLayer: some View {
        VStack {
            Spacer()
            
            HStack(alignment: .center, spacing: 50) {
                PhotoPickerView(selectedUIImage: $selectedPhoto)
                
                ZStack(alignment: .top) {
                    if camera.availableLenses.count > 0 {
                        CameraCycleButtonView(buttonText: displayZoomString) {
                            try? camera.cycleLens()
                        }
                        .offset(y: -75)
                    }
                    
                    CameraShutterButtonView {
                        withAnimation {
                            camera.takePhoto()
                        }
                    }
                }
                
                CameraFlashButtonView(flashMode: camera.flashMode) {
                    camera.toggleFlash()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding(.bottom)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Logic Helpers
extension CameraAndPhotoPickerView {
    private func setupCamera() async {
        do {
            try await camera.startCamera()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func handleTapToFocus(viewPoint: CGPoint) {
        focusLocation = viewPoint
        showFocusBox = true
        focusBoxScale = 1.5
        
        withAnimation(.easeOut(duration: 0.2)) {
            focusBoxScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFocusBox = false
        }
    }
}

#Preview {
    NavigationStack {
        CameraAndPhotoPickerView()
            .environment(MedicineViewModel())
            .environment(NavigationRouter())
    }
}
