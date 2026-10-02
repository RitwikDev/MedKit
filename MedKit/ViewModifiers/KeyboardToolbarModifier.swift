//
//  KeyboardToolbarModifier.swift
//  MedKit
//
//  Created by Rishik Dev on 02/10/26.
//

import SwiftUI

struct KeyboardToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    DismissKeyboardButtonView()
                }
            }
    }
}
