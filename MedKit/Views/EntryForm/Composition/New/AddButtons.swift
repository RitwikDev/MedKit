//
//  AddButtons.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct AddButtons: View {
    @Binding var offsetY: CGFloat
    
    var body: some View {
        HStack {
            Button {
                print("Add")
            } label: {
                Text("Add")
                    .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            Button {
                print("Add More")
            } label: {
                Text("Add More")
                    .frame(maxWidth: .infinity)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
        .background {
            Color(uiColor: .systemGroupedBackground)
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
                .ignoresSafeArea()
        }
        .padding(.horizontal)
        .offset(y: max(0, -offsetY / 3))
    }
}

#Preview {
    AddButtons(offsetY: .constant(0))
}
