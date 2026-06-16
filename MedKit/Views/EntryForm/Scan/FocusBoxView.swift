//
//  FocusBoxView.swift
//  MedKit
//
//  Created by Rishik Dev on 10/06/26.
//

import SwiftUI

struct FocusBoxView: View {
    let focusBoxScale: CGFloat
    let focusLocation: CGPoint

    private let focusBoxDimension: CGFloat = 70
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.yellow, lineWidth: 1.5)
            .frame(width: focusBoxDimension, height: focusBoxDimension)
            .scaleEffect(focusBoxScale)
            .position(focusLocation)
            .overlay(
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 4, height: 4)
                    .position(focusLocation)
            )
            .ignoresSafeArea()
    }
}

#Preview {
    FocusBoxView(
        focusBoxScale: 1,
        focusLocation: .zero
    )
}
