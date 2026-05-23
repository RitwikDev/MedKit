//
//  RoundedTintedButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 22/05/26.
//

import SwiftUI

struct RoundedTintedButtonView: View {
    let buttonAction: () -> Void
    let title: String
    let systemImage: String
    let tintColor: Color
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            Label(title, systemImage: systemImage)
                .labelStyle(.iconOnly)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.bordered)
        .tint(tintColor)
    }
}

#Preview {
    RoundedTintedButtonView(buttonAction: { },
                            title: "Title",
                            systemImage: "plus",
                            tintColor: .blue)
}
