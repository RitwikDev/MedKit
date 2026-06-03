//
//  CompositionFormView.swift
//  MedKit
//
//  Created by Rishik Dev on 31/05/26.
//

import SwiftUI

struct CompositionFormView: View {
    @Binding var composition: Composition
    let compositions: [Composition]
    let isInputDisabled: Bool
    
    private var isDuplicate: Bool {
        compositions.contains(where: { $0.id != composition.id && $0.equalsName(composition) })
    }
    
    var body: some View {
        Form {
            Section(content: {
                TextField("Name", text: $composition.name)
            }, header: {
                Text("Name")
            }, footer: {
                if (isDuplicate) {
                    Text("Composition already exists")
                        .foregroundStyle(.red)
                }
            })
            .disabled(isInputDisabled)
            
            StrengthSectionView(
                strengthAmount: $composition.strengthAmount,
                strengthUnit: $composition.strengthUnit
            )
            .disabled(isInputDisabled)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    CompositionFormView(
        composition: .constant(Composition(
            name: "Composition Name",
            strengthAmount: 500,
            strengthUnit: "mcg"
        )),
        compositions: [],
        isInputDisabled: false
    )
    .environment(MedicineViewModel())
}
