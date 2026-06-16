//
//  CameraShutterButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 10/06/26.
//

import SwiftUI

struct CameraShutterButtonView: View {
    let buttonAction: () -> Void
    
    var body: some View {
        Circle()
            .fill(.clear)
            .stroke(.white, lineWidth: 3)
            .frame(width: 80, height: 80)
            .overlay {
                Button(action: buttonAction) {
                    Circle()
                        .fill(.white)
                        .frame(width: 70, height: 70)
                }
            }
    }
}

#Preview {
    CameraShutterButtonView {
        print("Click!")
    }
}
