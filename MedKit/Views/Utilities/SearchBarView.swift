//
//  SearchBarView.swift
//  MedKit
//
//  Created by Ritwik Dev on 15/06/26.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            
            TextField("Search", text: self.$searchText)
            
            if !self.searchText.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .onTapGesture {
                        self.searchText = ""
                    }
            }
        }
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    
    SearchBarView(searchText: $searchText)
}
