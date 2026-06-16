//
//  StringExtension.swift
//  MedKit
//
//  Created by Ritwik Dev on 23/05/26.
//

import Foundation

extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var lowercasedAndTrimmed: String {
        self.lowercased().trimmed
    }
    
    var trimmedIsEmpty: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func trimmedLocalisedEquals(_ other: String) -> Bool {
        self.trimmed.localizedCaseInsensitiveCompare(other.trimmed) == .orderedSame
    }
}
