//
//  PDFView.swift
//

import SwiftUI
import PDFKit

struct PDFViewUI: UIViewRepresentable {
    
    let pdfView = PDFView()
    var data: Data?
    
    init(data: Data) {
        self.data = data
    }

    func makeUIView(context: Context) -> UIView {
        if let data = data {
            pdfView.document = PDFDocument(data: data)
            pdfView.autoScales = true
            pdfView.displaysPageBreaks = true
            pdfView.usePageViewController(true)
            pdfView.displayDirection = .horizontal
            if let pdfScrollView = pdfView.subviews.first?.subviews.first as? UIScrollView {
                pdfScrollView.showsHorizontalScrollIndicator = false
                pdfScrollView.showsVerticalScrollIndicator = false
            }
        }
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Empty
    }
}
