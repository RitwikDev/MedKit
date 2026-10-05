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
    
    func trimmedLocalizedCaseInsensitiveEquals(_ other: String) -> Bool {
        self.trimmed.localizedCaseInsensitiveCompare(other.trimmed) == .orderedSame
    }
    
    func getUrl() -> URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        if let match = matches.first {
            return match.url
        }
        return nil
    }
}
