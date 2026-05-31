//
//  TestAddCompositionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 31/05/26.
//

import SwiftUI

struct TestAddCompositionView: View {
    @State private var list: [Composition] = [
        .init(name: "Compost 1"),
        .init(name: "Compost 2"),
        .init(name: "Compost 3"),
        .init(name: "Compost 4"),
        .init(name: "Compost 5"),
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(list) { item in
                    AddCompositionView(composition: item)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                }
            }
        }
        .ignoresSafeArea()
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
    }
}

#Preview {
    TestAddCompositionView()
        .environment(MedicineViewModel())
}
