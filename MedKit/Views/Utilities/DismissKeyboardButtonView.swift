//
//  DismissKeyboardButtonView.swift
//  MedKit
//
//  Created by Rishik Dev on 02/10/26.
//

import SwiftUI

struct DismissKeyboardButtonView: View {
    var body: some View {
        Button {
            handleHideKeyboard()
        } label: {
            Label("Dismiss keyboard", systemImage: "keyboard.chevron.compact.down")
                .labelStyle(.iconOnly)
        }
    }
    
    private func handleHideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    DismissKeyboardButtonView()
}
