//
//  TagExtensions.swift
//  MedKit
//
//  Created by Ritwik Dev on 25/05/26.
//

import Foundation

extension Tag {
    func isDuplicate(of other: Tag) -> Bool {
        return self.id != other.id
        && self.value.trimmedLocalizedCaseInsensitiveEquals(other.value)
    }
}
