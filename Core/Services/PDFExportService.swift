import Foundation
import UIKit

enum PDFExportError: LocalizedError {
    case missingImage
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .missingImage: "A scan page image could not be loaded."
        case .invalidImage: "A scan page image is invalid."
        }
    }
}

actor PDFExportService {
    func render(document: ScanDocument, imageLoader: @Sendable (ScanPage) throws -> UIImage) throws -> Data {
        let pageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageBounds)
        var renderError: Error?

        let data = renderer.pdfData { context in
            for page in document.pages {
                let image: UIImage
                do {
                    image = try imageLoader(page)
                } catch {
                    renderError = error
                    return
                }
                guard image.size.width > 0, image.size.height > 0 else {
                    renderError = PDFExportError.invalidImage
                    return
                }
                context.beginPage()
                draw(image: image, title: document.title, in: pageBounds)
            }

            if !document.recognizedText.isEmpty {
                drawTextPages(document.recognizedText, title: "Recognized Text", in: pageBounds, context: context)
            }
        }

        if let renderError {
            throw renderError
        }
        return data
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

        let scale = min(available.width / size.width, available.height / size.height)
        let drawSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(
            x: available.midX - drawSize.width / 2,
            y: available.midY - drawSize.height / 2
        )
        image.draw(in: CGRect(origin: origin, size: drawSize))
    }

    private func drawTextPages(
        _ text: String,
        title: String,
        in pageBounds: CGRect,
        context: UIGraphicsPDFRendererContext
    ) {
        let margin: CGFloat = 42
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]

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

        var characterIndex = 0
        while characterIndex < body.length {
            context.beginPage()
            title.draw(at: CGPoint(x: margin, y: 32), withAttributes: titleAttributes)

            let remaining = body.attributedSubstring(
                from: NSRange(location: characterIndex, length: body.length - characterIndex)
            )
            let storage = NSTextStorage(attributedString: remaining)
            let layoutManager = NSLayoutManager()
            let container = NSTextContainer(size: bodyRect.size)
            container.lineFragmentPadding = 0
            layoutManager.addTextContainer(container)
            storage.addLayoutManager(layoutManager)

            let glyphRange = layoutManager.glyphRange(for: container)
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: bodyRect.origin)

            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            guard characterRange.length > 0 else { break }
            characterIndex += characterRange.length
        }
    }
}
