//
//  ExtensionTagsSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation

extension TagsSectionView {
    func removeTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
    }
}
