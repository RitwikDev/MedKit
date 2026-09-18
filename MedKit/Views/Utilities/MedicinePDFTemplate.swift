//
//  MedicinePDFTemplate.swift
//  MedKit
//
//  Created by Rishik Dev on 25/08/26.
//

import SwiftUI
import UIKit

struct MedicinePDFTemplate: View {
    let medicine: Medicine
    
    // Helper formatters
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Header
            Text("Medicine Record")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Divider()
            
            // MARK: - Basic Information
            Group {
                Text("Name: \(medicine.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let amount = medicine.strengthAmount, let unit = medicine.strengthUnit {
                    Text("Strength: \(amount, specifier: "%.2f") \(unit)")
                }
                
                if let mfgDate = medicine.manufacturedDate {
                    Text("Manufactured Date: \(dateFormatter.string(from: mfgDate))")
                }
                
                if let expDate = medicine.expiryDate {
                    Text("Expiry Date: \(dateFormatter.string(from: expDate))")
                }
            }
            
            // MARK: - Tags
            if !medicine.tags.isEmpty {
                let tagStrings = medicine.tags.map { $0.value }.joined(separator: ", ")
                Text("Tags: \(tagStrings)")
            }
            
            Divider()
            
            // MARK: - Composition
            if !medicine.composition.isEmpty {
                Text("Composition").font(.headline)
                ForEach(medicine.composition) { ingredient in
                    if let amount = ingredient.strengthAmount, let unit = ingredient.strengthUnit {
                        Text("• \(ingredient.name): \(amount, specifier: "%.2f") \(unit)")
                    } else {
                        Text("• \(ingredient.name)")
                    }
                }
                Divider()
            }
            
            // MARK: - Dosage Information
            if let dosage = medicine.dosage {
                Text("Dosage Details").font(.headline)
                
                if let qty = dosage.dosageQuantity {
                    Text("Quantity: \(qty, specifier: "%.2f")")
                }
                
                Text("Repeat Routine: \(dosage.repeatType.rawValue)")
                
                if let start = dosage.startDate {
                    Text("Start Date: \(dateFormatter.string(from: start))")
                }
                
                if let end = dosage.endDate {
                    Text("End Date: \(dateFormatter.string(from: end))")
                }
                
                if !dosage.reminderTimes.isEmpty {
                    let times = dosage.reminderTimes.map { timeFormatter.string(from: $0.time) }.joined(separator: ", ")
                    Text("Reminders: \(times)")
                }
                
                if !dosage.selectedDays.isEmpty {
                    let days = dosage.selectedDays.map { $0.rawValue }.joined(separator: ", ")
                    Text("Days: \(days)")
                }
                
                Divider()
            }
            
            // MARK: - Stock Information
            if let stock = medicine.stock {
                Text("Stock Inventory").font(.headline)
                Text("Available Quantity: \(stock.quantity, specifier: "%.2f") \(stock.unit)")
                
                if stock.endDate != .distantFuture {
                    Text("Estimated Depletion Date: \(dateFormatter.string(from: stock.endDate))")
                }
                Divider()
            }
            
            // MARK: - Custom Fields & Documents
            let customFields = medicine.getCustomFieldsSortedByLabel()
            if !customFields.isEmpty {
                Text("Additional Information & Documents").font(.headline)
                ForEach(customFields) { field in
                    renderCustomField(field)
                }
                Divider()
            }
            
            Spacer()
        }
        .padding(40)
        .frame(width: 595, alignment: .topLeading)
        .background(Color.white)
        .foregroundColor(.black)
    }
    
    // MARK: - Custom Field Renderer
    @ViewBuilder
    private func renderCustomField(_ field: CustomFieldValue) -> some View {
        let label = field.getLabel()
        
        VStack(alignment: .leading, spacing: 6) {
            switch field.getValue() {
            case .text(let text):
                Text("\(label): \(text)")
                
            case .date(let date):
                Text("\(label): \(dateFormatter.string(from: date))")
                
            case .list(let items):
                Text("\(label):")
                ForEach(items, id: \.self) { item in
                    Text("• \(item)").padding(.leading, 10)
                }
                
            case .documents(let docs):
                Text("\(label):")
                ForEach(docs) { doc in
                    let ext = doc.documentExtension.lowercased()
                    
                    let printableExtensions = [
                        "pdf", "jpg", "jpeg", "png", "heic", "txt", "text",
                        "docx", "doc", "xlsx", "xls", "pages", "numbers"
                    ]
                    
                    if printableExtensions.contains(ext) || doc.documentType == .photo {
                        Text("\(doc.name).\(doc.documentExtension) (Attached to end of document)")
                            .padding(.leading, 10)
                    } else {
                        Text("\(doc.name).\(doc.documentExtension) (File not printable)")
                            .padding(.leading, 10)
                            .foregroundColor(.gray)
                        }
                }
                
            case .none:
                Text("\(label): (Empty)")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MedicinePDFTemplate(medicine: .init())
}
