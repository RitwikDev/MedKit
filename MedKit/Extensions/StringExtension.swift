//
//  StringExtension.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import Foundation

extension String {
    func lowercasedTrimmed() -> String {
        self.lowercased().trimmed()
    }

    func trimmed() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
