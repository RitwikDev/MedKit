//
//  CardViewPreviewWrapper.swift
//  MedKit
//
//  Created by Rishik Dev on 31/05/26.
//

import SwiftUI

struct CardViewPreviewWrapper: View {
    @State private var mockItem = Composition()
    @State private var isEditMode = false
    
    var body: some View {
        VStack(spacing: 40) {
            // A toggle to easily turn edit mode on/off in the preview canvas
            Toggle("Toggle Edit Mode", isOn: $isEditMode)
                .padding(.horizontal, 40)
            
            BatchEntryCardView(
                item: $mockItem,
                isEditModeEnabled: $isEditMode,
                onRemoveCallback: { id in
                    print("Preview: Requested to remove item with ID: \(id)")
                }
            ) {
                CompositionFormView(
                    composition: $mockItem,
                    compositions: [],
                    isInputDisabled: isEditMode
                )
            }
        }
    }
}
