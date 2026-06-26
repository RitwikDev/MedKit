//
//  CircularButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 22/05/26.
//

import SwiftUI

struct CircularButtonView: View {
    var title: String = "Add"
    var systemImage: String = "plus"
    var tintColor: Color = .blue
    let buttonAction: () -> Void
    
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
    CircularButtonView(title: "Title",
                            systemImage: "plus",
                            tintColor: .blue,
                            buttonAction: {})
}
