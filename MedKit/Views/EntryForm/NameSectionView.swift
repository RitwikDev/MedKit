//
//  NameSectionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import SwiftUI

struct NameSectionView: View {
    @Binding var name: String
    
    var body: some View {
        Section("Name") {
            TextField("Name", text: $name)
                .autocorrectionDisabled()
        }
    }
}

#Preview {
    NameSectionView(name: .constant(""))
}
