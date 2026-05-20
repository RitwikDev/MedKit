//
//  SectionHeaderWithButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct SectionHeaderWithButtonView: View {
    let sectionHeader: String
    let buttonLabel: String
    let buttonSystemImage: String
    let buttonAction: () -> Void
    
    var body: some View {
        HStack {
            Text(sectionHeader)

            Spacer()

            Button {
                buttonAction()
            } label: {
                Label(buttonLabel, systemImage: buttonSystemImage)
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
            .buttonBorderShape(.circle)
        }
    }
}

#Preview {
    SectionHeaderWithButtonView(sectionHeader: "Header",
                                buttonLabel: "Button",
                                buttonSystemImage: "plus",
                                buttonAction: { })
}
