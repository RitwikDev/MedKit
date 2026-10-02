//
//  RoundedRectBackground.swift
//  MedKit
//
//  Created by Rishik Dev on 01/10/26.
//

import SwiftUI

struct RoundedRectBackgroundViewModifier: ViewModifier {
    let colour: Color
    
    func body(content: Content) -> some View {
        content
            .background(colour)
            .clipShape(.rect(cornerRadius: 10))
    }
}
