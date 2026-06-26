//
//  PhotoPreviewView.swift
//  MedKit
//
//  Created by Rishik Dev on 15/06/26.
//

import SwiftUI
#if targetEnvironment(simulator)
import SimulatorCameraService
#else
import DeviceCameraService
#endif

struct PhotoPreviewView: View {
    let cameraService: CameraService
    let photo: UIImage
    let dismissButtonAction: () -> Void
    
    @Environment(NavigationRouter.self) private var router
    @State private var geminiManager: GeminiManager = .init()
    @State private var shouldDisableView: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            ZoomablePhotoView(photo: photo)
             
            if (geminiManager.analysisStatus == .loading) {
                loadingView
            }
        }
        .disabled(shouldDisableView)
        .onChange(of: geminiManager.analysisStatus) { oldValue, newValue in
            switch newValue {
            case .reset:
                shouldDisableView = false
            case .loading:
                shouldDisableView = true
            case .success:
                if let cMedicineModel = geminiManager.medicine {
                    let medicine = Medicine(fromCodable: cMedicineModel)
                    geminiManager.analysisStatus = .reset
                    dismissButtonAction()
                    router.navigate(to: .medicineForm(for: medicine))
                }
            case .failure:
                showAlert.toggle()
            }
        }
        .alert("Analysis failed", isPresented: $showAlert) {
            Button("Dismiss") {
                geminiManager.analysisStatus = .reset
            }
        } message: {
            Text(geminiManager.errorMessage)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: dismissButtonAction) {
                    Label("Cancel", systemImage: "xmark")
                }
                .disabled(shouldDisableView)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Button("Analyse") {
                        geminiManager.analyseImage(photo)
                    }
                                        
                    Menu {
                        Button("Analyse") {
                            geminiManager.analyseImage(photo, isMock: true)
                        }
                        
                        Button("Fail") {
                            geminiManager.analyseImage(photo, isMock: true, shouldFail: true)
                        }
                    } label: {
                        Text("Mock")
                    }
                } label: {
                    Label("Analysis Menu", systemImage: "ellipsis")
                }
                .disabled(shouldDisableView)
            }
        }
        .onAppear {
            cameraService.stopCamera()
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Analysing")
        }
        .padding()
        .tint(.primary)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        PhotoPreviewView(
            cameraService: CameraService(),
            photo: UIImage(named: "cat")!
        ) {
            print("Dismiss")
        }
        .environment(NavigationRouter())
    }
}
