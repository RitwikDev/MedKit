//
//  UIKitMultiDatePicker.swift
//  MedKit
//
//  Created by Rishik Dev on 21/08/26.
//


import SwiftUI
import UIKit

struct UIKitMultiDatePicker: UIViewRepresentable {
    @Binding var selection: Set<DateComponents>
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        
        // Inherit the environment's calendar and locale
        calendarView.calendar = Calendar.current
        calendarView.locale = Locale.current
        
        // Configure the multi-date selection behavior
        let multiSelection = UICalendarSelectionMultiDate(delegate: context.coordinator)
        multiSelection.selectedDates = Array(selection)
        calendarView.selectionBehavior = multiSelection
        
        return calendarView
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Ensure UIKit updates if the @State changes externally,
        // but avoid redundant updates to prevent infinite loops.
        guard let multiSelection = uiView.selectionBehavior as? UICalendarSelectionMultiDate else { return }
        
        let currentUIKitSelection = Set(multiSelection.selectedDates)
        if currentUIKitSelection != selection {
            multiSelection.selectedDates = Array(selection)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // The Coordinator handles UIKit delegate callbacks and pushes them to SwiftUI
    class Coordinator: NSObject, UICalendarSelectionMultiDateDelegate {
        var parent: UIKitMultiDatePicker
        
        init(_ parent: UIKitMultiDatePicker) {
            self.parent = parent
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
            parent.selection.insert(dateComponents)
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
            parent.selection.remove(dateComponents)
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
            return true
        }
        
        func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
            return true
        }
    }
}
