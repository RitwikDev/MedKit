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
    
    private func generateMergedPDFData() async -> Data {
        // 1. Render the base SwiftUI view with perfect Native CGContext Pagination
        let basePDFData = await MainActor.run {
            let pdfView = MedicinePDFTemplate(medicine: medicine)
            let renderer = ImageRenderer(content: pdfView)
            
            let pageWidth: CGFloat = 595
            let pageHeight: CGFloat = 842
            
            renderer.proposedSize = ProposedViewSize(width: pageWidth, height: nil)
            
            let data = NSMutableData()
            var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            
            guard let consumer = CGDataConsumer(data: data as CFMutableData),
                  let pdfContext = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return Data()
            }
            
            renderer.render { size, renderContext in
                let totalPages = max(1, Int(ceil(size.height / pageHeight)))
                let baseTranslation = pageHeight - size.height
                
                for page in 0..<totalPages {
                    pdfContext.beginPDFPage(nil)
                    pdfContext.saveGState()
                    
                    let yOffset = baseTranslation + (CGFloat(page) * pageHeight)
                    pdfContext.translateBy(x: 0, y: yOffset)
                    
                    renderContext(pdfContext)
                    
                    pdfContext.restoreGState()
                    pdfContext.endPDFPage()
                }
            }
            
            pdfContext.closePDF()
            return data as Data
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
        let printableRect = paperRect.insetBy(dx: 40, dy: 40)
        
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
