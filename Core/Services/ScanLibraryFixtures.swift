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
                recognizedText: """
                INDEPENDENT SERVICES AGREEMENT
                Client: Sample Client LLC
                Vendor: Example Studio Co.
                Effective date: May 17, 2026
                Total: 4,800.00
                """,
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
            scansThisMonth = 0
            try save()
        } catch {
            self.documents = documents
            scansThisMonth = 0
        }
    }

    private func fixtureDocument(
        title: String,
        filename: String,
        recognizedText: String,
        style _: FixtureDocumentStyle
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
            ],
            isFixture: true
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

            drawPaperBackground()
            drawDocument(style: style, title: title)
        }

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw ScanLibraryError.jpegEncodingFailed
        }
        try FileManager.default.createDirectory(at: imagesURL, withIntermediateDirectories: true)
        try data.write(to: imagesURL.appendingPathComponent(filename), options: [.atomic])
    }

    private func drawPaperBackground() {
        let paper = CGRect(x: 142, y: 122, width: 916, height: 1256)
        UIColor(red: 0.98, green: 0.98, blue: 0.95, alpha: 1).setFill()
        UIBezierPath(roundedRect: paper, cornerRadius: 14).fill()

        UIColor(red: 0.87, green: 0.85, blue: 0.78, alpha: 1).setStroke()
        let outline = UIBezierPath(roundedRect: paper.insetBy(dx: 1, dy: 1), cornerRadius: 14)
        outline.lineWidth = 3
        outline.stroke()
    }

    private func drawDocument(style: FixtureDocumentStyle, title: String) {
        switch style {
        case .contract:
            drawContract()
        case .receipt:
            drawReceipt()
        case .form:
            drawForm(title: title)
        }
    }

    private func drawContract() {
        drawAccentBar(x: 222, y: 215, width: 310)
        drawText("INDEPENDENT SERVICES AGREEMENT", x: 222, y: 270, size: 36, weight: .bold)
        drawText("Sample Client LLC", x: 222, y: 334, size: 26, weight: .semibold)
        drawText("Agreement No. SC-2026-0517", x: 720, y: 334, size: 22, weight: .medium)
        drawRule(y: 390)

        let rows = [
            ("Effective date", "May 17, 2026"),
            ("Vendor", "Example Studio Co."),
            ("Services", "Document cleanup, OCR review, and PDF archive delivery"),
            ("Project total", "$4,800.00")
        ]
        var currentY = 430
        for row in rows {
            drawText(row.0.uppercased(), x: 222, y: currentY, size: 18, weight: .bold, color: .darkGray)
            drawText(row.1, x: 470, y: currentY - 2, size: 22, weight: .regular)
            currentY += 58
        }

        drawSection(
            "1. Scope of Work",
            body: "Vendor will prepare, scan, and organize client records into searchable PDF files. " +
                "Final archives will be delivered with readable names and verified page order.",
            y: 690
        )
        drawSection(
            "2. Payment Terms",
            body: "Client will pay fifty percent on approval and the balance on delivery. " +
                "Late invoices may pause additional archive work until account status is current.",
            y: 840
        )
        drawSection(
            "3. Confidentiality",
            body: "Both parties will protect sample records and will not disclose private contents " +
                "except as needed to complete the archive.",
            y: 990
        )

        drawSignatureLine(label: "Client signature", x: 222, y: 1210)
        drawSignatureLine(label: "Vendor signature", x: 650, y: 1210)
        drawText("SAMPLE DOCUMENT - FICTIONAL DATA", x: 222, y: 1322, size: 18, weight: .bold, color: .gray)
    }

    private func drawReceipt() {
        drawAccentBar(x: 222, y: 215, width: 210)
        drawText("TAX RECEIPT", x: 222, y: 270, size: 42, weight: .bold)
        drawText("May 17, 2026", x: 770, y: 282, size: 24, weight: .semibold)
        drawText("Receipt #TX-4418", x: 222, y: 340, size: 24, weight: .medium)
        drawRule(y: 405)

        let rows = [
            ("Archival folders", "$42.00"),
            ("Scanner rental", "$55.00"),
            ("OCR processing", "$18.50"),
            ("Sales tax", "$12.92")
        ]
        var currentY = 470
        for row in rows {
            drawText(row.0, x: 222, y: currentY, size: 28, weight: .regular)
            drawText(row.1, x: 820, y: currentY, size: 28, weight: .semibold)
            drawRule(y: currentY + 48, color: UIColor(white: 0.78, alpha: 1), lineWidth: 2)
            currentY += 90
        }

        drawText("TOTAL", x: 222, y: 880, size: 34, weight: .bold)
        drawText("$128.42", x: 775, y: 880, size: 34, weight: .bold)
        drawCheckbox(x: 222, y: 1045)
        drawText("Paid by card ending 4242", x: 315, y: 1060, size: 26, weight: .medium)
        drawText("SAMPLE RECEIPT - FICTIONAL DATA", x: 222, y: 1322, size: 18, weight: .bold, color: .gray)
    }

    private func drawForm(title: String) {
        drawAccentBar(x: 222, y: 215, width: 260)
        drawText(title.uppercased(), x: 222, y: 270, size: 40, weight: .bold)
        drawText("Patient intake worksheet", x: 222, y: 332, size: 24, weight: .medium, color: .darkGray)
        drawRule(y: 400)

        let fields = ["Name", "Date of birth", "Insurance ID", "Primary contact", "Preferred pharmacy"]
        var currentY = 470
        for field in fields {
            drawText(field, x: 222, y: currentY, size: 24, weight: .semibold)
            drawRule(y: currentY + 42, color: UIColor(white: 0.35, alpha: 1), lineWidth: 3)
            currentY += 105
        }

        drawText("Reason for visit", x: 222, y: 1035, size: 24, weight: .semibold)
        drawBox(CGRect(x: 222, y: 1082, width: 700, height: 150))
        drawCheckbox(x: 222, y: 1265)
        drawText("I confirm this sample information is accurate.", x: 315, y: 1280, size: 22, weight: .medium)
    }

    private func drawSection(_ heading: String, body: String, y yPosition: Int) {
        drawText(heading, x: 222, y: yPosition, size: 25, weight: .bold)
        drawMultilineText(body, x: 222, y: yPosition + 40, width: 710, size: 22)
    }

    private func drawSignatureLine(label: String, x xPosition: Int, y yPosition: Int) {
        drawRule(y: yPosition, x: xPosition, width: 310, color: UIColor(white: 0.16, alpha: 1), lineWidth: 4)
        drawText(label, x: xPosition, y: yPosition + 18, size: 18, weight: .medium, color: .darkGray)
    }

    private func drawAccentBar(x xPosition: Int, y yPosition: Int, width: Int) {
        UIColor(red: 0.06, green: 0.64, blue: 0.78, alpha: 1).setFill()
        UIBezierPath(roundedRect: CGRect(x: xPosition, y: yPosition, width: width, height: 24), cornerRadius: 12).fill()
    }

    private func drawRule(
        y yPosition: Int,
        x xPosition: Int = 222,
        width: Int = 710,
        color: UIColor = .black,
        lineWidth: CGFloat = 3
    ) {
        color.setStroke()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.move(to: CGPoint(x: xPosition, y: yPosition))
        path.addLine(to: CGPoint(x: xPosition + width, y: yPosition))
        path.stroke()
    }

    private func drawBox(_ rect: CGRect) {
        UIColor(white: 0.2, alpha: 1).setStroke()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        path.lineWidth = 3
        path.stroke()
    }

    private func drawCheckbox(x xPosition: Int, y yPosition: Int) {
        UIColor(red: 0.06, green: 0.64, blue: 0.78, alpha: 1).setStroke()
        let box = UIBezierPath(roundedRect: CGRect(x: xPosition, y: yPosition, width: 68, height: 68), cornerRadius: 6)
        box.lineWidth = 8
        box.stroke()

        let mark = UIBezierPath()
        mark.lineWidth = 9
        mark.lineCapStyle = .round
        mark.move(to: CGPoint(x: xPosition + 15, y: yPosition + 38))
        mark.addLine(to: CGPoint(x: xPosition + 31, y: yPosition + 54))
        mark.addLine(to: CGPoint(x: xPosition + 56, y: yPosition + 17))
        mark.stroke()
    }

    private func drawText(
        _ text: String,
        x xPosition: Int,
        y yPosition: Int,
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor = .black
    ) {
        text.draw(
            at: CGPoint(x: xPosition, y: yPosition),
            withAttributes: [
                .font: UIFont.systemFont(ofSize: size, weight: weight),
                .foregroundColor: color
            ]
        )
    }

    private func drawMultilineText(_ text: String, x xPosition: Int, y yPosition: Int, width: Int, size: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 7
        text.draw(
            in: CGRect(x: xPosition, y: yPosition, width: width, height: 110),
            withAttributes: [
                .font: UIFont.systemFont(ofSize: size),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]
        )
    }
}

private enum FixtureDocumentStyle {
    case contract
    case receipt
    case form
}
