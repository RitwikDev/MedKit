//
//  LineView.swift
//  MedKit
//
//  Created by Ritwik Dev on 14/07/26.
//

import SwiftUI

struct LineView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

#Preview {
    LineView()
}
