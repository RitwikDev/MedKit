//
//  AddCompositionView.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//

import SwiftUI

struct AddCompositionView: View {
    let composition: Composition
    
    @State private var offset = CGSize.zero
    @State private var removeRectangleRadius: CGFloat = 0
    @State private var gestureHeightPercent: CGFloat = 0
    
    private var absOffsetHeight: CGFloat {
        abs(offset.height)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: removeRectangleRadius)
                    .fill(.red)
                    .overlay {
                        Image(systemName: "trash")
                            .resizable()
                            .padding(absOffsetHeight == 0 ? 0 : 30)
                            .frame(maxWidth: 150, maxHeight: 150)
                    }
                    .frame(width: absOffsetHeight, height: absOffsetHeight)
                    .opacity(gestureHeightPercent * 1.25)
                
                compositionEntryForm
            }
            
            AddButtons(offsetY: $offset.height)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
    
    var compositionEntryForm: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                EditCompositionView(composition: composition)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()
                
                Button {
                    withAnimation(.bouncy) {
                        gestureHeightPercent = 1
                        offset = CGSize(width: 0, height: -geometry.frame(in: .local).height)
                    }
                } label: {
                    Label("Remove", systemImage: "minus")
                        .labelStyle(.iconOnly)
                        .padding(5)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .offset(y: min(0, offset.height))
            .opacity(1.0 - gestureHeightPercent)
            .highPriorityGesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            return
                        }
                        
                        withAnimation(.bouncy) {
                            offset = gesture.translation
                            gestureHeightPercent = absOffsetHeight / geometry.frame(in: .local).height
                            
                            removeRectangleRadius = 50
                        }
                    }
                    .onEnded { gesture in
                        let shouldRemove = abs(gesture.translation.height) > geometry.frame(in: .local).height / 2
                        if (shouldRemove) {
                            print("Remove")
                        } else {
                            withAnimation(.bouncy) {
                                offset = .zero
                            }
                        }
                    }
            )
        }
    }
}

#Preview {
    AddCompositionView(composition: .init())
        .environment(MedicineViewModel())
}
