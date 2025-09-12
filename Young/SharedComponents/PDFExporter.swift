import UIKit
import PDFKit

class PDFExporter {
    
    static func exportJSONToMultiPagePDF(json: [PostDetails],
                                         fileName: String = "SharesData.pdf",
                                         from viewController: UIViewController) {
        
        // 1. Convert Codable object to pretty JSON string
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(json),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            LogHandler.debugLog("❌ Could not convert decoded object to JSON string")
            return
        }
        
        let pageWidth: CGFloat = 595.2  // A4
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 20.0
        let textFont = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        let lineHeight = textFont.lineHeight
        let linesPerPage = Int((pageHeight - 2 * margin) / lineHeight)
        
        let lines = jsonString.components(separatedBy: .newlines)
        let pdfDocument = PDFDocument()
        var currentLines: [String] = []
        var pageIndex = 0
        
        for (i, line) in lines.enumerated() {
            currentLines.append(line)
            if currentLines.count == linesPerPage || i == lines.count - 1 {
                if let page = createPDFPage(from: currentLines, font: textFont, pageSize: CGSize(width: pageWidth, height: pageHeight), margin: margin) {
                    pdfDocument.insert(page, at: pageIndex)
                    pageIndex += 1
                    currentLines.removeAll()
                }
            }
        }
        
        // 2. Save to file
        guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = docDir.appendingPathComponent(fileName)
        
        if pdfDocument.write(to: fileURL) {
            LogHandler.debugLog("✅ PDF saved at: \(fileURL)")
            
            // 3. Present options to view or share
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            viewController.present(activityVC, animated: true)
        } else {
            LogHandler.debugLog("❌ Failed to save PDF")
        }
    }
    
    private static func createPDFPage(from lines: [String],
                                      font: UIFont,
                                      pageSize: CGSize,
                                      margin: CGFloat) -> PDFPage? {
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [.font: font]
            var y = margin
            for line in lines {
                let rect = CGRect(x: margin, y: y, width: pageSize.width - 2 * margin, height: font.lineHeight)
                line.draw(in: rect, withAttributes: attrs)
                y += font.lineHeight
            }
        }
        
        guard let document = PDFDocument(data: data),
              let firstPage = document.page(at: 0) else {
            return nil
        }
        return firstPage
    }
}
