//
//  ColourExtension.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation
import SwiftUI

extension Color {
    init(rgbRed: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.init(
            red: rgbRed / 255,
            green: green / 255,
            blue: blue / 255,
            opacity: opacity
        )
    }
}
