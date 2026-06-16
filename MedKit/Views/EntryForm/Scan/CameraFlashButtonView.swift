//
//  CameraFlashButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 11/06/26.
//


import SwiftUI
#if targetEnvironment(simulator)
import SimulatorCameraService
#else
import DeviceCameraService
#endif

struct CameraFlashButtonView: View {
    let flashMode: CameraFlashMode
    let buttonAction: () -> Void
    
    var iconName: String {
        switch flashMode {
        case .on: return "bolt.fill"
        case .off: return "bolt.slash.fill"
        case .auto: return "bolt.badge.a.fill"
        }
    }
    
    var body: some View {
        Button(action: buttonAction) {
            Image(systemName: iconName)
                .foregroundColor(flashMode == .on ? .yellow : .white)
                .frame(width: 48, height: 48)
                .background(.black.opacity(0.5))
                .clipShape(.circle)
        }
    }
}
