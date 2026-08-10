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
}
