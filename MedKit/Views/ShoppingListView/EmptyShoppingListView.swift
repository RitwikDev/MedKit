//
//  EmptyShoppingListView.swift
//  MedKit
//
//  Created by Rishik Dev on 21/09/26.
//

import SwiftUI

struct EmptyShoppingListView: View {
    var body: some View {
        EmptyEntryView(text: "Shopping List is Empty")
            .foregroundStyle(.secondary)
            .font(.title3)
            .fontWeight(.black)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyShoppingListView()
}
