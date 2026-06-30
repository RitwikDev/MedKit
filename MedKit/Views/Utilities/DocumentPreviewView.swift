//
//  DocumentPreviewView.swift
//  MedKit
//
//  Created by Rishik Dev on 28/06/26.
//

import QuickLook
import SwiftUI

struct DocumentPreviewView: UIViewControllerRepresentable {
    let document: Document

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // QuickLook handles its own internal updates
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: DocumentPreviewView
        var temporaryFileURL: URL?

        init(parent: DocumentPreviewView) {
            self.parent = parent
            super.init()
            self.temporaryFileURL = writeDataToTemporaryFile()
        }

        /// Writes the Core Data binary data to the temporary directory so QuickLook can read it.
        private func writeDataToTemporaryFile() -> URL? {
            let tempDirectory = FileManager.default.temporaryDirectory
            let url = tempDirectory.appendingPathComponent("\(parent.document.name).\(parent.document.documentExtension)")
            
            do {
                try parent.document.documentData.write(to: url, options: .atomic)
                return url
            } catch {
                print("Failed to write temporary file for QuickLook: \(error.localizedDescription)")
                return nil
            }
        }

        // MARK: - QLPreviewControllerDataSource
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return temporaryFileURL != nil ? 1 : 0
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            guard let url = temporaryFileURL else {
                fatalError("QuickLook attempted to load a missing file URL.")
            }
            return url as NSURL
        }
        
        // MARK: - Cleanup
        
        /// Automatically deletes the temporary file from the disk when the view is destroyed to prevent storage bloat.
        deinit {
            if let url = temporaryFileURL {
                try? FileManager.default.removeItem(at: url)
            }
        }
    }
}
