//
//  BatchEntryCardView.swift
//  MedKit
//
//  Created by Rishik Dev on 31/05/26.
//


import SwiftUI

struct BatchEntryCardView<Element: Identifiable, Content: View>: View {
    @Binding var item: Element
    @Binding var isEditModeEnabled: Bool
    let onRemoveCallback: (Element.ID) -> Void
    
    // The view builder allows us to inject any form content
    @ViewBuilder let content: () -> Content
    
    @State private var isJiggling: Bool = false
    @State private var offset: CGSize = CGSize.zero
    @State private var gestureHeightPercent: CGFloat = 0
    
    private var absOffsetHeight: CGFloat {
        abs(offset.height)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                content()
                    .clipRoundedRectangleIf(isEditModeEnabled, cornerRadius: 20)
                    .overlay {
                        if (isEditModeEnabled) {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.red, lineWidth: 5)
                        }
                    }
                    .scrollIndicators(.never)
                    .scrollDisabled(isEditModeEnabled)
                    .opacity(1.0 - gestureHeightPercent)
                
                if (isEditModeEnabled) {
                    removeButton(geometry: geometry)
                        .padding(-20)
                }
            }
            .scaleEffect(isEditModeEnabled ? 0.75 : 1)
            .rotationEffect(.degrees(isEditModeEnabled && isJiggling ? 1.5 : 0))
            .onChange(of: isEditModeEnabled) { oldValue, newValue in
                if newValue {
                    withAnimation(.interactiveSpring(duration: 0.25).repeatForever(autoreverses: true)) {
                        isJiggling = true
                    }
                } else {
                    withAnimation(.interactiveSpring(duration: 0.25)) {
                        isJiggling = false
                    }
                }
            }
            .offset(y: min(0, offset.height))
            .onTapGesture {
                withAnimation(.bouncy) {
                    isEditModeEnabled = false
                }
            }
            .simultaneousGesture(
                isEditModeEnabled ?
                DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .onChanged { gesture in
                        if gesture.translation.height > 0 { return }
                        
                        withAnimation(.bouncy) {
                            offset = gesture.translation
                            gestureHeightPercent = absOffsetHeight / geometry.frame(in: .local).height
                        }
                    }
                    .onEnded { gesture in
                        let shouldRemove = abs(gesture.translation.height) > geometry.frame(in: .local).height / 2
                        if shouldRemove {
                            withAnimation(.bouncy(duration: 0.25)) {
                                offset = CGSize(width: 0, height: -geometry.frame(in: .local).height)
                            } completion: {
                                onRemoveCallback(item.id)
                            }
                        } else {
                            withAnimation(.bouncy) {
                                offset = .zero
                            }
                        }
                    }
                : nil
            )
            .onAppear {
                if (isEditModeEnabled) {
                    withAnimation(.interactiveSpring(duration: 0.25).repeatForever(autoreverses: true)) {
                        isJiggling = true
                    }
                }
            }
        }
    }
    
    private func removeButton(geometry: GeometryProxy) -> some View {
        Button {
            withAnimation(.bouncy(duration: 0.25)) {
                gestureHeightPercent = 1
                offset = CGSize(width: 0, height: -geometry.frame(in: .local).height)
            } completion: {
                onRemoveCallback(item.id)
            }
        } label: {
            Label("Remove", systemImage: "minus")
                .labelStyle(.iconOnly)
                .padding(10)
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.borderedProminent)
        .tint(.red)
    }
}

#Preview {
    CardViewPreviewWrapper()
}
