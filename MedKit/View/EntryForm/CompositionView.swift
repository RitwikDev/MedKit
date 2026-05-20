//
//  CompositionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CompositionView: View {
    @Binding var composition: [CompositionModel]
    
    var body: some View {
        VStack {
            ForEach($composition) { $composition in
                VStack {
                    TextField(composition.name, text: $composition.name)
                    StrengthView(strength: $composition.strength)
                }
            }
        }
    }
}

#Preview {
    CompositionView(composition: .constant([]))
}
