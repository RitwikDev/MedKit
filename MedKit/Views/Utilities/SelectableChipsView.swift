//
//  SelectableChipsView.swift
//  MedKit
//
//  Created by Ritwik Dev on 18/07/26.
//

import SwiftUI

struct SelectableChipsView: View {
    let options: Set<String>
    let onSelect: (String) -> Void
    
    private var sortedOptions: [String] {
        Array(options).sorted()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Array(sortedOptions.enumerated()), id: \.element) { index, option in
                    ChipItemView(
                        title: option,
                        delay: Double(index) * 0.08,
                        onSelect: { onSelect(option) }
                    )
                }
            }
            .id(options)
        }
    }
}

struct ChipItemView: View {
    let title: String
    let delay: Double
    var tint: Color = .blue
    let onSelect: () -> Void
    
    @State private var isAppeared = false
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            Text(title)
        }
        .tint(tint)
        .buttonStyle(.bordered)
        .opacity(isAppeared ? 1 : 0)
        .scaleEffect(isAppeared ? 1.0 : 0.5)
        .onAppear {
            withAnimation(
                .spring(response: 0.4, dampingFraction: 0.7)
                .delay(delay)
            ) {
                isAppeared = true
            }
        }
    }
}

#Preview {
    SelectableChipsView(
        options: Set([
            "Porsche",
            "BMW",
            "Mercedes",
            "Audi",
            "Maruti",
            "Tesla",
            "Honda",
            "Toyota",
            "Hyundai",
            "HM",
        ]),
        onSelect: { selected in print(selected)}
    )
}
