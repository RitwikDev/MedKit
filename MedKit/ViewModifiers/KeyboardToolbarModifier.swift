//
//  KeyboardToolbarModifier.swift
//  MedKit
//
//  Created by Rishik Dev on 02/10/26.
//

import SwiftUI

struct KeyboardToolbarModifier<PrimaryContent: View>: ViewModifier {
    @ViewBuilder let primaryContent: () -> PrimaryContent
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if (PrimaryContent.self != EmptyView.self) {
                        Spacer()
                        primaryContent()
                    }
                    Spacer()
                    DismissKeyboardButtonView()
                }
            }
    }
}
