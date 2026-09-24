//
//  CalendarEvent.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import Foundation
import SwiftUI

struct CalendarEvent: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let title: String
    let color: Color
    
    var medicineID: UUID? = nil
    var isTaken: Bool = false
    var takenByUserID: String? = nil
    var eventType: EventType = .dosage
    
    enum EventType: Hashable {
        case dosage, expiry, stockout
    }
}
