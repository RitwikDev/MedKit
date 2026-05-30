//
//  ViewExtension.swift
//  MedKit
//
//  Created by Rishik Dev on 28/05/26.
//

import Foundation
import SwiftUI

struct SheetModifier: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        content
            .interactiveDismissDisabled()
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension View {
    func sheetModifier(titled title: String) -> some View {
        modifier(SheetModifier(title: title))
    }
}
