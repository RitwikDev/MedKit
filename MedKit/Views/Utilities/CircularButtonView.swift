//
//  CircularButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 22/05/26.
//

import SwiftUI

struct CircularButtonView: View {
    var title: String = "Delete"
    var systemImage: String = "xmark"
    var tintColor: Color = .red
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
