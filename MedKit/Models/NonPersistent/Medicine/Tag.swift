//
//  Tag.swift
//  MedKit
//
//  Created by Rishik Dev on 23/05/26.
//

import Foundation
import SwiftData

struct Tag: Identifiable, Equatable, Hashable, Comparable {
    let id: UUID
    var value: String
    
    init(id: UUID = UUID(), value: String = "") {
        self.id = id
        self.value = value
    }
    
    static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.value < rhs.value
    }
}
