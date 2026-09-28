//
//  SettingsCustomFieldsListView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import SwiftUI

struct SettingsCustomFieldsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
            ForEach(globalDataViewModel.allCustomFields) { customField in
                VStack(alignment: .leading) {
                    Text(customField.label)
                    Text(customField.dataType.rawValue)
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            .onDelete(perform: globalDataViewModel.deleteCustomField)
        }
        .navigationTitle("All Custom Fields")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsCustomFieldsListView()
        .environment(GlobalDataViewModel())
}
