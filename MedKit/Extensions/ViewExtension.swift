//
//  ViewExtension.swift
//  MedKit
//
//  Created by Rishik Dev on 28/05/26.
//

import Foundation
import SwiftUI

extension View {
    func keyboardToolbar() -> some View {
        self.modifier(KeyboardToolbarModifier())
    }
    
    func roundedRectBackground(colour: Color) -> some View {
        modifier(RoundedRectBackgroundViewModifier(colour: colour))
    }
}
