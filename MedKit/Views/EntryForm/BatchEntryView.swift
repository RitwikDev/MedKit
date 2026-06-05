//
//  BatchEntryView.swift
//  MedKit
//
//  Created by Rishik Dev on 31/05/26.
//

import SwiftUI

struct BatchEntryView<Element: Identifiable, Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [Element]
    @State private var isEditModeEnabled: Bool = false
    @State private var scrolledID: Element.ID?
    
    let title: String
    let newItemProvider: () -> Element
    let isDataValid: ([Element]) -> Bool
    let onSave: ([Element]) -> Void
    
    // Passes the binding and the disabled state down to the specific form
    @ViewBuilder let formContent: (Binding<Element>, [Element], Bool) -> Content
    
    init(
        title: String,
        initialItems: [Element],
        newItemProvider: @escaping () -> Element,
        isDataValid: @escaping ([Element]) -> Bool,
        onSave: @escaping ([Element]) -> Void,
        @ViewBuilder formContent: @escaping (Binding<Element>, [Element], Bool) -> Content
    ) {
        self.title = title
        // Ensure we always start with at least one form if the array is empty
        self._items = State(initialValue: initialItems.isEmpty ? [newItemProvider()] : initialItems)
        self.newItemProvider = newItemProvider
        self.isDataValid = isDataValid
        self.onSave = onSave
        self.formContent = formContent
    }
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach($items) { $item in
                        BatchEntryCardView(
                            item: $item,
                            isEditModeEnabled: $isEditModeEnabled,
                            onRemoveCallback: onRemove
                        ) {
                            formContent($item, items, isEditModeEnabled)
                        }
//                        .padding(1)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .id(item.id)
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrolledID)
            .onScrollPhaseChange { oldPhase, newPhase in
                if (newPhase == .interacting) {
                    dismissKeyboard()
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                Button("Done") {
                    onSave(items)
                    dismiss()
                }
                .disabled(!isDataValid(items))

                Menu {
                    Button(isEditModeEnabled ? "Done" : "Edit") {
                        withAnimation(.bouncy) {
                            isEditModeEnabled.toggle()
                        }
                    }
                    
                    Button("Add Another") {
                        onAddMore()
                    }
                    .disabled(!isDataValid(items))
                } label: {
                    Label("More", systemImage: "ellipsis")
                }
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func onAddMore() {
        dismissKeyboard()
        let newItem = newItemProvider()
        items.append(newItem)
        
        DispatchQueue.main.async {
            withAnimation(.bouncy) {
                scrolledID = newItem.id
            }
        }
    }
    
    private func onRemove(id: Element.ID) {
        withAnimation(.spring(duration: 0.25)) {
            items.removeAll { $0.id == id }
            
            if (items.isEmpty) {
                items.append(newItemProvider())
            }
        }
    }
}

#Preview {
    NavigationStack {
        BatchEntryView(
            title: "Add Composition",
            // Pass some dummy initial data so the preview isn't empty
            initialItems: [
                Composition(),
                Composition()
            ],
            newItemProvider: { Composition() },
            isDataValid: { items in
                // Basic mock validation
                items.contains { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            },
            onSave: { finalCompositions in
                print("Preview Save Tapped! Items: \(finalCompositions.count)")
            }
        ) { compositionBinding, newComposition, isInputDisabled in
            
            CompositionFormView(
                composition: compositionBinding,
                compositions: [],
                isInputDisabled: isInputDisabled
            )
            
        }
    }
}
