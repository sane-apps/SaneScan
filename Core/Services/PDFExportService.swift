import Foundation
import UIKit

enum PDFExportError: LocalizedError {
    case missingImage

    var errorDescription: String? {
        switch self {
        case .missingImage: "A scan page image could not be loaded."
        }
    }
}

actor PDFExportService {
    func render(document: ScanDocument, imageLoader: @Sendable (ScanPage) throws -> UIImage) throws -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)

        return renderer.pdfData { context in
            for page in document.pages {
                context.beginPage()
                let image = (try? imageLoader(page)) ?? UIImage()
                draw(image: image, title: document.title, in: pageBounds)
            }

            if !document.recognizedText.isEmpty {
                context.beginPage()
                drawText(document.recognizedText, title: "Recognized Text", in: pageBounds)
            }
        }
    }

    private func draw(image: UIImage, title: String, in pageBounds: CGRect) {
        let margin: CGFloat = 36
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: margin, y: 24), withAttributes: titleAttributes)

        let available = pageBounds.insetBy(dx: margin, dy: 70)
        let size = image.size
        guard size.width > 0, size.height > 0 else { return }

        let scale = min(available.width / size.width, available.height / size.height)
        let drawSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(
            x: available.midX - drawSize.width / 2,
            y: available.midY - drawSize.height / 2
        )
        image.draw(in: CGRect(origin: origin, size: drawSize))
    }

    private func drawText(_ text: String, title: String, in pageBounds: CGRect) {
        let margin: CGFloat = 42
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: margin, y: 32), withAttributes: titleAttributes)

        let bodyRect = CGRect(
            x: margin,
            y: 72,
            width: pageBounds.width - margin * 2,
            height: pageBounds.height - 104
        )
        let body = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
        )
        body.draw(in: bodyRect)
    }
}
