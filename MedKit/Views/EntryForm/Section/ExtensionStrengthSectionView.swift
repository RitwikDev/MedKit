//
//  ExtensionStrengthSectionView.swift
//  MedKit
//
//  Created by Rishik Dev on 27/05/26.
//

import Foundation

extension StrengthSectionView {
    func handleStrengthChange() {
        if let amount = strengthAmount {
            strengthAmountString = String(format: "%g", amount)
        } else {
            strengthAmountString = ""
        }
        
        strengthUnitString = strengthUnit ?? ""
    }
    
    func handleOnChange(oldValue: String, newValue: String) {
        let components = newValue.description.split(separator: ".")
        
        if components.count > 1 && components[1].count > 2 {
            strengthAmountString = oldValue
        }
        
        strengthAmount = Float(strengthAmountString) ?? nil
    }
}
