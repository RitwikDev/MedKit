//
//  CustomFieldDefinitionListItem.swift
//  MedKit
//
//  Created by Ritwik Dev on 07/06/26.
//

import SwiftUI

struct CustomFieldDefinitionListItem: View {
    let customField: CustomField
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.customField.label)
            
            Text("Field Type") + Text(": ") + Text(self.customField.dataType.localizedName)
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }
}

#Preview {
    CustomFieldDefinitionListItem(
        customField: CustomField(
            label: "Text Field",
            dataType: .text
        )
    )
}
