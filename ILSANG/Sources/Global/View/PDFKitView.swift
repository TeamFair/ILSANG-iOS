//
//  PDFKitView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/26/25.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        let pdfView = PDFView()
        if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
           let document = PDFDocument(url: url) {
            pdfView.document = document
            pdfView.autoScales = true
        }
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
    }
}
