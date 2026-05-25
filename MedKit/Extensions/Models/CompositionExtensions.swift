//
//  CompositionExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Composition {
    init(from model: CompositionModel) {
        self.id = UUID()
        self.persistentIdentifier = model.id
        self.name = model.name
        self.strengthAmount = model.strengthAmount
        self.strengthUnit = model.strengthUnit
    }
}
