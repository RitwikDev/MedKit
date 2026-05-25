//
//  TagExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Tag {
    init(from model: TagModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.value = model.value
    }
}
