//
//  LineView.swift
//  MedKit
//
//  Created by Ritwik Dev on 14/07/26.
//

import SwiftUI

struct LineView: Shape {
    var isVertical: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isVertical {
            path.move(to: CGPoint(x: rect.midX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        }
        return path
    }
}

#Preview {
    LineView()
}
