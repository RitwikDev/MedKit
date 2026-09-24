//
//  MedicinePDFExporter.swift
//  MedKit
//
//  Created by Rishik Dev on 25/08/26.
//

import SwiftUI
import CoreServices
import UniformTypeIdentifiers
import PDFKit
import WebKit

// MARK: - Exporter

struct MedicinePDFExporter: Transferable {
    let medicine: Medicine
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .pdf) { exporter in
            return await exporter.generateMergedPDFData()
        }
        .suggestedFileName { exporter in
            "\(exporter.medicine.name).pdf"
        }
    }
    
    public func generateMergedPDFData() async -> Data {
        await MainActor.run {
            NotificationCenter.default.post(name: NotificationManager.shareProcessingStarted, object: nil)
        }
        
        defer {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NotificationManager.shareProcessingFinished, object: nil)
            }
        }
        
        // 1. Generate beautifully paginated HTML-based PDF
        let basePDFData = await MainActor.run {
            let htmlString = generateHTMLForMedicine()
            return renderHTMLToPDF(html: htmlString)
        }
        
        guard let combinedPDF = PDFDocument(data: basePDFData) else { return basePDFData }
        
        // 2. Iterate and append supported document types
        let customFields = medicine.getCustomFieldsSortedByLabel()
        for field in customFields {
            if case .documents(let docs) = field.getValue() {
                for doc in docs {
                    let ext = doc.documentExtension.lowercased()
                    let filename = "\(doc.name).\(doc.documentExtension)"
                    
                    // Handle PDFs (Now strictly normalised to A4)
                    if ext == "pdf", let attachedPDF = PDFDocument(data: doc.documentData) {
                        if let divider = createDividerPage(for: filename) { append(pdf: divider, to: combinedPDF) }
                        
                        if let normalisedData = normalizePDFDimensions(sourcePDF: attachedPDF),
                           let normalisedPDF = PDFDocument(data: normalisedData) {
                            append(pdf: normalisedPDF, to: combinedPDF)
                        }
                    }
                    // Handle Images
                    else if doc.documentType == .photo || ["jpg", "jpeg", "png", "heic"].contains(ext) {
                        if let image = UIImage(data: doc.documentData),
                           let imagePDFData = renderImageToPDF(image: image, filename: filename),
                           let imagePDF = PDFDocument(data: imagePDFData) {
                            append(pdf: imagePDF, to: combinedPDF)
                        }
                    }
                    // Handle Plain Text
                    else if ["txt", "text"].contains(ext) {
                        if let textString = String(data: doc.documentData, encoding: .utf8),
                           let textPDFData = renderTextToPDF(text: textString, filename: filename),
                           let textPDF = PDFDocument(data: textPDFData) {
                            append(pdf: textPDF, to: combinedPDF)
                        }
                    }
                    // Handle Rich Documents
                    else if ["docx", "doc", "xlsx", "xls", "pages", "numbers"].contains(ext) {
                        let convertedData = await RichDocumentConverter().convertToPDF(data: doc.documentData, fileExtension: ext)
                        
                        if let data = convertedData, let convertedPDF = PDFDocument(data: data) {
                            if let divider = createDividerPage(for: filename) { append(pdf: divider, to: combinedPDF) }
                            
                            // Normalise the converted document just in case it generated off-size
                            if let normalisedData = normalizePDFDimensions(sourcePDF: convertedPDF),
                               let normalisedPDF = PDFDocument(data: normalisedData) {
                                append(pdf: normalisedPDF, to: combinedPDF)
                            }
                        }
                    }
                }
            }
        }
        
        return combinedPDF.dataRepresentation() ?? basePDFData
    }
    
    // MARK: - HTML Generation
    
    private func generateHTMLForMedicine() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
        body { font-family: -apple-system, system-ui, Helvetica, sans-serif; padding: 0; margin: 0; color: #1c1c1e; line-height: 1.4; }
        .header { background-color: #f2f2f7; padding: 24px; border-radius: 12px; margin-bottom: 24px; page-break-inside: avoid; }
        h1 { margin: 0 0 8px 0; font-size: 32px; color: #000; font-weight: 700; }
        .header-value { font-size: 18px; font-weight: 600; color: #3a3a3c; margin-bottom: 12px; }
        .tag-container { margin-top: 12px; }
        .tag { display: inline-block; background-color: #e5e5ea; color: #1c1c1e; padding: 5px 12px; border-radius: 16px; font-size: 13px; margin-right: 6px; margin-bottom: 6px; font-weight: 600; }
        h2 { font-size: 20px; color: #007aff; border-bottom: 2px solid #007aff; padding-bottom: 6px; margin-top: 32px; margin-bottom: 16px; page-break-after: avoid; }
        .grid { display: flex; flex-wrap: wrap; margin-bottom: 16px; }
        .cell { width: 50%; margin-bottom: 16px; page-break-inside: avoid; }
        .label { font-size: 11px; text-transform: uppercase; color: #8e8e93; font-weight: 700; letter-spacing: 0.6px; margin-bottom: 4px; display: block; }
        .value { font-size: 16px; font-weight: 500; color: #1c1c1e; }
        ul { margin: 0; padding-left: 24px; }
        li { margin-bottom: 8px; font-size: 16px; font-weight: 500; }
        .bullet-label { font-weight: normal; color: #636366; font-size: 14px; }
        .section { page-break-inside: auto; }
        .item-block { margin-bottom: 12px; page-break-inside: avoid; }
        </style>
        </head>
        <body>
        """
        
        // Header
        html += "<div class='header'>"
        html += "<h1>\(medicine.name)</h1>"
        if let strength = medicine.strengthAmount, let unit = medicine.strengthUnit {
            let val = strength.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", strength) : String(format: "%.2f", strength)
            html += "<div class='header-value'>Strength: \(val) \(unit)</div>"
        }
        if !medicine.tags.isEmpty {
            html += "<div class='tag-container'>"
            for tag in medicine.tags {
                html += "<span class='tag'>\(tag.value)</span>"
            }
            html += "</div>"
        }
        html += "</div>"
        
        // Basic Info
        if medicine.manufacturedDate != nil || medicine.expiryDate != nil {
            html += "<div class='section'><h2>Basic Information</h2><div class='grid'>"
            if let mfg = medicine.manufacturedDate {
                html += "<div class='cell'><span class='label'>Manufactured Date</span><span class='value'>\(formatter.string(from: mfg))</span></div>"
            }
            if let exp = medicine.expiryDate {
                html += "<div class='cell'><span class='label'>Expiry Date</span><span class='value'>\(formatter.string(from: exp))</span></div>"
            }
            html += "</div></div>"
        }
        
        // Composition
        if !medicine.composition.isEmpty {
            html += "<div class='section'><h2>Composition</h2><ul>"
            for ing in medicine.composition {
                var text = "<strong>\(ing.name)</strong>"
                if let a = ing.strengthAmount, let u = ing.strengthUnit {
                    let val = a.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", a) : String(format: "%.2f", a)
                    text += " <span class='bullet-label'>(\(val) \(u))</span>"
                }
                html += "<li style='page-break-inside: avoid;'>\(text)</li>"
            }
            html += "</ul></div>"
        }
        
        // Dosage
        if let dosage = medicine.dosage {
            html += "<div class='section'><h2>Dosage & Routine</h2><div class='grid'>"
            if let q = dosage.dosageQuantity {
                let val = q.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", q) : String(format: "%.2f", q)
                html += "<div class='cell'><span class='label'>Quantity per Dose</span><span class='value'>\(val)</span></div>"
            }
            html += "<div class='cell'><span class='label'>Routine Type</span><span class='value'>\(dosage.repeatType.rawValue.capitalized)</span></div>"
            if let s = dosage.startDate {
                html += "<div class='cell'><span class='label'>Start Date</span><span class='value'>\(formatter.string(from: s))</span></div>"
            }
            if let e = dosage.endDate {
                html += "<div class='cell'><span class='label'>End Date</span><span class='value'>\(formatter.string(from: e))</span></div>"
            }
            if !dosage.reminderTimes.isEmpty {
                let times = dosage.reminderTimes.map { timeFormatter.string(from: $0.time) }.joined(separator: ", ")
                html += "<div class='cell'><span class='label'>Reminder Times</span><span class='value'>\(times)</span></div>"
            }
            if !dosage.selectedDays.isEmpty {
                let days = dosage.selectedDays.map { $0.rawValue.prefix(3) }.joined(separator: ", ")
                html += "<div class='cell'><span class='label'>Active Days</span><span class='value'>\(days)</span></div>"
            }
            html += "</div></div>"
        }
        
        // Stock
        if let stock = medicine.stock {
            html += "<div class='section'><h2>Inventory</h2><div class='grid'>"
            let val = stock.quantity.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", stock.quantity) : String(format: "%.2f", stock.quantity)
            html += "<div class='cell'><span class='label'>Currently Available</span><span class='value'>\(val) \(stock.unit)</span></div>"
            if stock.endDate != .distantFuture {
                html += "<div class='cell'><span class='label'>Estimated Depletion</span><span class='value'>\(formatter.string(from: stock.endDate))</span></div>"
            }
            html += "</div></div>"
        }
        
        // Custom Fields
        let customFields = medicine.getCustomFieldsSortedByLabel()
        if !customFields.isEmpty {
            html += "<div class='section'><h2>Additional Information</h2>"
            for field in customFields {
                html += "<div class='item-block'>"
                html += "<span class='label'>\(field.getLabel())</span>"
                switch field.getValue() {
                case .text(let t):
                    html += "<div class='value'>\(t)</div>"
                case .date(let d):
                    html += "<div class='value'>\(formatter.string(from: d))</div>"
                case .list(let arr):
                    html += "<ul>"
                    for item in arr { html += "<li>\(item)</li>" }
                    html += "</ul>"
                case .documents(let docs):
                    html += "<ul>"
                    for doc in docs {
                        let e = doc.documentExtension.lowercased()
                        let p = ["pdf", "jpg", "jpeg", "png", "heic", "txt", "text", "docx", "doc", "xlsx", "xls", "pages", "numbers"].contains(e) || doc.documentType == .photo
                        let name = "\(doc.name).\(doc.documentExtension)"
                        if p {
                            html += "<li>\(name) <span class='bullet-label'>(Attached)</span></li>"
                        } else {
                            html += "<li>\(name) <span class='bullet-label'>(Not printable)</span></li>"
                        }
                    }
                    html += "</ul>"
                case .none:
                    html += "<div class='value' style='color: #8e8e93;'>(Empty)</div>"
                }
                html += "</div>"
            }
            html += "</div>"
        }
        
        html += "</body></html>"
        return html
    }
    
    private func renderHTMLToPDF(html: String) -> Data {
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        let paperRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let printableRect = paperRect.insetBy(dx: 48, dy: 48)
        
        render.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    // MARK: - Helpers
    
    private func append(pdf source: PDFDocument, to destination: PDFDocument) {
        for i in 0..<source.pageCount {
            if let page = source.page(at: i) {
                destination.insert(page, at: destination.pageCount)
            }
        }
    }
    
    /// Forces an attached PDF to fit perfectly onto A4 pages (595x842)
    private func normalizePDFDimensions(sourcePDF: PDFDocument) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let paperRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: paperRect, format: format)
        
        return renderer.pdfData { context in
            for i in 0..<sourcePDF.pageCount {
                guard let page = sourcePDF.page(at: i) else { continue }
                context.beginPage()
                
                let cgContext = context.cgContext
                let pageBounds = page.bounds(for: .cropBox)
                
                // Calculate scale to fit within A4 preserving aspect ratio
                let widthRatio = paperRect.width / pageBounds.width
                let heightRatio = paperRect.height / pageBounds.height
                let scale = min(widthRatio, heightRatio)
                
                let scaledWidth = pageBounds.width * scale
                let scaledHeight = pageBounds.height * scale
                let xOffset = (paperRect.width - scaledWidth) / 2.0
                let yOffset = (paperRect.height - scaledHeight) / 2.0
                
                cgContext.saveGState()
                
                // 1. Move to the centered offset
                cgContext.translateBy(x: xOffset, y: yOffset)
                
                // 2. Flip the coordinate system for CoreGraphics
                cgContext.translateBy(x: 0, y: scaledHeight)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                
                // 3. Scale down the PDF content
                cgContext.scaleBy(x: scale, y: scale)
                
                // 4. Offset any internal cropBox origin shifts from the original file
                cgContext.translateBy(x: -pageBounds.origin.x, y: -pageBounds.origin.y)
                
                // Draw the vector data onto the context
                page.draw(with: .cropBox, to: cgContext)
                
                cgContext.restoreGState()
            }
        }
    }
    
    private func renderImageToPDF(image: UIImage, filename: String) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margins: CGFloat = 40
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.black]
            let title = NSAttributedString(string: "Attachment: \(filename)", attributes: titleAttrs)
            title.draw(at: CGPoint(x: margins, y: margins))
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: margins, y: margins + 25))
            path.addLine(to: CGPoint(x: pageWidth - margins, y: margins + 25))
            UIColor.lightGray.setStroke()
            path.stroke()
            
            let imageStartY: CGFloat = margins + 45
            let availableHeight = pageHeight - margins - imageStartY
            
            let aspectWidth = (pageWidth - (margins * 2)) / image.size.width
            let aspectHeight = availableHeight / image.size.height
            let scale = min(aspectWidth, aspectHeight)
            
            let scaledWidth = image.size.width * scale
            let scaledHeight = image.size.height * scale
            
            let x = (pageWidth - scaledWidth) / 2.0
            let y = imageStartY + (availableHeight - scaledHeight) / 2.0
            
            image.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
        }
    }
    
    private func renderTextToPDF(text: String, filename: String) -> Data? {
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margins: CGFloat = 40
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.black]
            let title = NSAttributedString(string: "Attachment: \(filename)", attributes: titleAttrs)
            title.draw(at: CGPoint(x: margins, y: margins))
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: margins, y: margins + 25))
            path.addLine(to: CGPoint(x: pageWidth - margins, y: margins + 25))
            UIColor.lightGray.setStroke()
            path.stroke()
            
            let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black]
            let attributedText = NSAttributedString(string: text, attributes: textAttributes)
            
            let textRect = CGRect(x: margins, y: margins + 45, width: pageWidth - (margins * 2), height: pageHeight - (margins * 2) - 45)
            attributedText.draw(in: textRect)
        }
    }
    
    private func createDividerPage(for filename: String) -> PDFDocument? {
        let format = UIGraphicsPDFRendererFormat()
        let paperRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: paperRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let subtitleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .semibold), .foregroundColor: UIColor.gray]
            let subtitle = NSAttributedString(string: "ATTACHMENT", attributes: subtitleAttrs)
            subtitle.draw(at: CGPoint(x: 40, y: 380))
            
            let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22, weight: .bold), .foregroundColor: UIColor.black]
            let title = NSAttributedString(string: filename, attributes: titleAttrs)
            title.draw(in: CGRect(x: 40, y: 400, width: 515, height: 60))
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 40, y: 460))
            path.addLine(to: CGPoint(x: 555, y: 460))
            UIColor.lightGray.setStroke()
            path.lineWidth = 1
            path.stroke()
        }
        
        return PDFDocument(data: data)
    }
}

// MARK: - Rich Document Converter

@MainActor
class RichDocumentConverter: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<Data?, Never>?
    
    func convertToPDF(data: Data, fileExtension: String) async -> Data? {
        let fileName = UUID().uuidString
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
            .appendingPathExtension(fileExtension)
        
        do {
            try data.write(to: tempURL)
        } catch {
            return nil
        }
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 595, height: 842))
        self.webView = webView
        webView.navigationDelegate = self
        
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            webView.loadFileURL(tempURL, allowingReadAccessTo: tempURL.deletingLastPathComponent())
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let pdfData = renderWebViewToPDF(webView: webView)
        continuation?.resume(returning: pdfData)
        continuation = nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(returning: nil)
        continuation = nil
    }
    
    private func renderWebViewToPDF(webView: WKWebView) -> Data {
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(webView.viewPrintFormatter(), startingAtPageAt: 0)
        
        let paperRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let printableRect = paperRect.insetBy(dx: 48, dy: 48)
        
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let format = UIGraphicsPDFRendererFormat()
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: paperRect, format: format)
        
        return pdfRenderer.pdfData { context in
            for i in 0..<renderer.numberOfPages {
                context.beginPage()
                renderer.drawPage(at: i, in: paperRect)
            }
        }
    }
}
