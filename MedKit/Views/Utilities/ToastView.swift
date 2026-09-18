//
//  ToastView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/08/26.
//

import SwiftUI

struct ToastView: View {
    let toastMessage: String
    
    var body: some View {
        Text(toastMessage)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(1)
    }
}

#Preview {
    ToastView(toastMessage: "Toast")
}
