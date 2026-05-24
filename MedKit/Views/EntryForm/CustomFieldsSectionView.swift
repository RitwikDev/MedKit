//
//  CustomFieldsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CustomFieldsSectionView: View {
    @Binding var customFields: [CustomFieldModel]
    let buttonAction: () -> Void
    
    var body: some View {
        Section("Custom Fields") {
            ForEach($customFields) { $customField in
                switch customField.value {
                case .date(let dateValue):
                    DatePicker(
                        "Select Date",
                        selection: Binding(
                            get: { dateValue },
                            set: { customField.value = .date($0) }
                        )
                    )
                    
                case .number(let floatValue):
                    // TextField requires a Binding<String>, so we map the Float to String and back
                    TextField(
                        "Enter Number",
                        text: Binding(
                            get: { String(floatValue) },
                            set: { newValue in
                                if let newFloat = Float(newValue) {
                                    customField.value = .number(newFloat)
                                }
                            }
                        )
                    )
                    .keyboardType(.decimalPad) // Good UX for numeric inputs
                    
                case .text(let textValue):
                    TextField(
                        "Enter Text",
                        text: Binding(
                            get: { textValue },
                            set: { customField.value = .text($0) }
                        )
                    )
                    
                case .list(let arrayValue):
                    // For an array of strings, you usually want to render a list of fields
                    // or let them select/edit items. Here is how you access each element safely:
                    VStack(alignment: .leading) {
                        ForEach(arrayValue.indices, id: \.self) { index in
                            TextField(
                                "Item \(index + 1)",
                                text: Binding(
                                    get: { arrayValue[index] },
                                    set: { newValue in
                                        var updatedList = arrayValue
                                        updatedList[index] = newValue
                                        customField.value = .list(updatedList)
                                    }
                                )
                            )
                        }
                    }
                }
            }
            
            Button("Add Custom Field") { buttonAction() }
        }
    }
}

#Preview {
    CustomFieldsSectionView(customFields: .constant([
        CustomFieldModel(label: "Storage Method", value: .text("Store in a cool, dry place"))
    ]),
                            buttonAction: { })
}
