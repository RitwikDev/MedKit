//
//  CameraCycleButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 10/06/26.
//

import SwiftUI

struct CameraCycleButtonView: View {
    let buttonText: String
    let buttonAction: () -> Void
    
    var body: some View {
        Button(action: buttonAction) {
            Text(buttonText)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    CameraCycleButtonView(buttonText: "1x") {
        print("Cycle Camera")
    }
}
