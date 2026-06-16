//
//  MedicineCustomFieldFormView.swift
//  MedKit
//
//  Created by Ritwik Dev on 14/06/26.
//

import SwiftUI

private struct TextFieldListItem: Identifiable, Equatable {
    var id = UUID()
    var text: String
}

struct MedicineCustomFieldFormView: View {
    let customFieldDefinition: CustomField
    @Binding var customFieldValue: CustomFieldValue
    
    @State private var text: String = ""
    @State private var date: Date = .now
    @State private var textList: [TextFieldListItem] = []
    
    @FocusState private var focusedFieldID: UUID?
    
    var body: some View {
        Form {
            Section(customFieldDefinition.label) {
                switch customFieldDefinition.dataType {
                case .text:
                    TextField("Write something...", text: $text, axis: .vertical)
                        .lineLimit(5)
                case .date:
                    DatePicker("Choose date", selection: $date, displayedComponents: .date)
                case .list:
                    listOptions
                }
            }
        }
        .onAppear {
            customFieldValue.definition = customFieldDefinition
            customFieldValue.textValue = nil
            customFieldValue.dateValue = nil
            customFieldValue.listValue = nil
        }
        .onChange(of: text) { oldValue, newValue in
            // This condition is required because self.text is being reused for self.textList
            if customFieldDefinition.dataType == .text {
                customFieldValue.textValue = newValue
            }
        }
        .onChange(of: date) { oldValue, newValue in
            customFieldValue.dateValue = newValue
        }
        .onChange(of: textList) { oldValue, newValue in
            customFieldValue.listValue = newValue.map { $0.text.trimmed }
        }
    }
    
    private var listOptions: some View {
        Group {
            HStack {
                TextField("Write something...", text: $text)
                CircularButtonView(
                    title: "Add",
                    systemImage: "plus",
                    tintColor: .blue
                ) {
                    withAnimation {
                        textList.append(.init(text: text.trimmed))
                    }
                    text = ""
                }
                .disabled(text.trimmedIsEmpty)
            }
            
            ForEach($textList) { $textItem in
                TextField("Write something...", text: $textItem.text)
                    .focused($focusedFieldID, equals: textItem.id)
            }
            .onDelete(perform: deleteListItems)
        }
        .onChange(of: focusedFieldID) { oldFocusedID, newFocusedID in
            print("Removing 1")
            if let lostFocusID = oldFocusedID {
                print("Removing 2")
                if let index = textList.firstIndex(where: { $0.id == lostFocusID }) {
                    print("Removing 3 \(index) \(textList[index].text)")
                    if textList[index].text.trimmedIsEmpty {
                        print("Removing 4 \(index)")
                        withAnimation {
                            _ = textList.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteListItems(_ indexSet: IndexSet) {
        textList.remove(atOffsets: indexSet)
    }
}

#Preview {
    MedicineCustomFieldFormView(
        customFieldDefinition: .init(label: "Actors", dataType: .list),
        customFieldValue: .constant(.init())
    )
}
