//
//  CustomFieldDataType.swift
//  MedKit
//
//  Created by Ritwik Dev on 06/06/26.
//


import Foundation

enum CustomFieldDataType: String, Codable, CaseIterable, Identifiable {
    case text = "Text"
    case date = "Date"
    case list = "List"
    case documents = "Documents"
    
    var id: Self { self }
}
