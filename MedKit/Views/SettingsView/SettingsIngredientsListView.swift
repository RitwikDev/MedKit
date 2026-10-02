//
//  SettingsIngredientsListView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/09/26.
//

import SwiftUI

struct SettingsIngredientsListView: View {
    @Environment(GlobalDataViewModel.self) private var globalDataViewModel
    
    var body: some View {
        List {
            ForEach(globalDataViewModel.allIngredients) { ingredient in
                Text(ingredient.fullName)
            }
            .onDelete(perform: globalDataViewModel.deleteIngredient)
        }
        .navigationTitle("All Ingredients")
    }
}

#Preview {
    SettingsIngredientsListView()
        .environment(GlobalDataViewModel())
}
