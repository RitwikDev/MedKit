//
//  ModelContextExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 29/05/26.
//

import Foundation
import SwiftData

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
