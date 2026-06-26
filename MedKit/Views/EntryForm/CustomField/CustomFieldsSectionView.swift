//
//  CustomFieldsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 20/05/26.
//

import SwiftUI

struct CustomFieldsSectionView: View {
    @Environment(NavigationRouter.self) private var router
    @Environment(MedicineEditorViewModel.self) private var medicineEditorViewModel
    
    @State private var text: String = ""
    
    var body: some View {
        @Bindable var bindableViewModel = medicineEditorViewModel
        
        ForEach($bindableViewModel.medicine.customFields) { customField in
            Section(customField.wrappedValue.getLabel()) {
                switch customField.wrappedValue.definition?.dataType {
                case .text:
                    TextField("Enter value", text: Binding(
                        get: { customField.wrappedValue.textValue ?? "" },
                        set: { customField.wrappedValue.textValue = $0 }
                    ), axis: .vertical)
                    
                case .date:
                    DatePicker("Select Date", selection: Binding(
                        get: { customField.wrappedValue.dateValue ?? .now },
                        set: { customField.wrappedValue.dateValue = $0 }
                    ), displayedComponents: .date)
                    
                case .list:
                    if let list = customField.wrappedValue.listValue {
                        HStack {
                            TextField("Write something...", text: $text)
                            CircularButtonView(
                                title: "Add",
                                systemImage: "plus",
                                tintColor: .blue
                            ) {
                                withAnimation {
                                    medicineEditorViewModel.addCustomListItem(
                                        to: customField.wrappedValue,
                                        value: text.trimmed,
                                    )
                                }
                                text = ""
                            }
                            .disabled(text.trimmedIsEmpty)
                        }
                        
                        ForEach(list, id: \.self) { item in
                            Text(item)
                        }
                        .onDelete { indexSet in
                            medicineEditorViewModel.deleteCustomListItem(from: customField.wrappedValue, at: indexSet)
                        }
                    }
                    
                case .none:
                    EmptyView()
                }
            }
        }
        
        Button("Add Field") {
            router.navigate(to: .addCustomFields(medicineEditorViewModel: medicineEditorViewModel))
        }
    }
}

#Preview {
    Form {
        CustomFieldsSectionView()
    }
    .environment(MedicineEditorViewModel(
        medicine: .init(
            customFields: [
                .init(
                    textValue: "Sherlock Holmes",
                    definition: .init(
                        label: "Show",
                        dataType: .text
                    )
                ),
                .init(
                    dateValue: Calendar.current.date(
                        from: .init(year: 1984, month: 4, day: 24)
                    ) ?? .now,
                    definition: .init(
                        label: "Date",
                        dataType: .date
                    )
                ),
                .init(
                    textListValue: [
                        "Jeremy Brett",
                        "David Burke",
                        "Edward Hardwicke"
                    ],
                    definition: .init(
                        label: "Actors",
                        dataType: .list
                    )
                ),
            ]
        )
    ))
    .environment(NavigationRouter())
}
