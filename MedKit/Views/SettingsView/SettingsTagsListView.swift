//
//  SettingsTagsListView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import SwiftUI

struct SettingsTagsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
            ForEach(globalDataViewModel.allTags) { tag in
                Text(tag.value)
            }
            .onDelete(perform: globalDataViewModel.deleteTag)
        }
        .navigationTitle("All Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsTagsListView()
        .environment(GlobalDataViewModel())
}
