import UIKit

extension ScanLibrary {
    func installUITestFixtureIfNeeded(arguments: [String] = ProcessInfo.processInfo.arguments) {
        if arguments.contains("--sanescan-reset-library") {
            resetForUITesting()
        }
        guard arguments.contains("--sanescan-ui-fixtures") else { return }
        installFixtureDocuments()
    }

    func resetForUITesting() {
        documents = []
        scansThisMonth = 0
        try? FileManager.default.removeItem(at: rootURL)
        try? FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: exportsURL, withIntermediateDirectories: true)
        try? save()
    }

    func installFixtureDocuments() {
        let documents = [
            fixtureDocument(
                title: "Contract Packet",
                filename: "fixture-contract-packet.jpg",
                recognizedText: "SERVICE AGREEMENT\nClient: Northstar Studio\nSigned May 17, 2026",
                style: .contract
            ),
            fixtureDocument(
                title: "Tax Receipt",
                filename: "fixture-tax-receipt.jpg",
                recognizedText: "TAX RECEIPT\nOffice supplies\nTotal 128.42",
                style: .receipt
            ),
            fixtureDocument(
                title: "Clinic Intake Form",
                filename: "fixture-clinic-form.jpg",
                recognizedText: "INTAKE FORM\nName\nDate\nInsurance ID",
                style: .form
            )
        ]

        do {
            for document in documents {
                if let page = document.pages.first {
                    let documentStyle = styles[document.title] ?? .contract
                    try writeFixtureImage(filename: page.imageFilename, title: document.title, style: documentStyle)
                }
            }
            self.documents = documents
            scansThisMonth = documents.count
            try save()
        } catch {
            self.documents = documents
            scansThisMonth = documents.count
        }
    }

    private func fixtureDocument(
        title: String,
        filename: String,
        recognizedText: String,
        style: FixtureDocumentStyle
    ) -> ScanDocument {
        ScanDocument(
            title: title,
            mode: .document,
            pages: [
                ScanPage(
                    imageFilename: filename,
                    enhancedFilename: filename,
                    recognizedText: recognizedText
                )
            ]
        )
    }

    private var styles: [String: FixtureDocumentStyle] {
        [
            "Contract Packet": .contract,
            "Tax Receipt": .receipt,
            "Clinic Intake Form": .form
        ]
    }

    private func writeFixtureImage(filename: String, title: String, style: FixtureDocumentStyle) throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 1600))
        let image = renderer.image { context in
            UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 1200, height: 1600))

            UIColor(red: 0.97, green: 0.98, blue: 0.96, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(x: 150, y: 130, width: 900, height: 1300), cornerRadius: 18).fill()

            UIColor(red: 0.06, green: 0.64, blue: 0.78, alpha: 1).setFill()
            UIBezierPath(roundedRect: CGRect(x: 240, y: 245, width: 420, height: 34), cornerRadius: 17).fill()

            UIColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1).setStroke()
            for index in 0..<style.lineCount {
                let lineY = style.firstLineY + (index * style.lineSpacing)
                let width = style.shortLineIndexes.contains(index) ? 460 : style.lineWidth
                let path = UIBezierPath()
                path.lineWidth = 18
                path.lineCapStyle = .round
                path.move(to: CGPoint(x: 240, y: lineY))
                path.addLine(to: CGPoint(x: 240 + width, y: lineY))
                path.stroke()
            }

            UIColor(red: 0.06, green: 0.64, blue: 0.78, alpha: 1).setStroke()
            let box = UIBezierPath(roundedRect: CGRect(x: 240, y: 1040, width: 220, height: 150), cornerRadius: 10)
            box.lineWidth = 14
            box.stroke()

            let mark = UIBezierPath()
            mark.lineWidth = 16
            mark.lineCapStyle = .round
            mark.move(to: CGPoint(x: 280, y: 1124))
            mark.addLine(to: CGPoint(x: 330, y: 1168))
            mark.addLine(to: CGPoint(x: 420, y: 1064))
            mark.stroke()

            title.uppercased().draw(
                at: CGPoint(x: 240, y: 300),
                withAttributes: [
                    .font: UIFont.boldSystemFont(ofSize: 58),
                    .foregroundColor: UIColor.black
                ]
            )
            "Scanned document".draw(
                at: CGPoint(x: 240, y: 1220),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 42, weight: .medium),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw ScanLibraryError.jpegEncodingFailed
        }
        try FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        try data.write(to: imagesURL.appendingPathComponent(filename), options: [.atomic])
    }
}

private enum FixtureDocumentStyle {
    case contract
    case receipt
    case form

    var firstLineY: Int {
        switch self {
        case .contract: 405
        case .receipt: 450
        case .form: 430
        }
    }

    var lineSpacing: Int {
        switch self {
        case .contract: 96
        case .receipt: 118
        case .form: 132
        }
    }

    var lineCount: Int {
        switch self {
        case .contract: 7
        case .receipt: 5
        case .form: 6
        }
    }

    var lineWidth: Int {
        switch self {
        case .contract: 680
        case .receipt: 540
        case .form: 640
        }
    }

    var shortLineIndexes: Set<Int> {
        switch self {
        case .contract: [2, 5]
        case .receipt: [1, 3]
        case .form: [0, 2, 4]
        }
    }
}
