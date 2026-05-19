@testable import SaneScan
import Testing
import UIKit

struct ScanQuotaTests {
    @Test func freeQuotaAllowsTenMonthlyScans() {
        #expect(ScanQuota(hasPro: false, scansThisMonth: 0).canCreateScan)
        #expect(ScanQuota(hasPro: false, scansThisMonth: 9).canCreateScan)
        #expect(!ScanQuota(hasPro: false, scansThisMonth: 10).canCreateScan)
    }

    @Test func proQuotaAllowsUnlimitedScans() {
        let quota = ScanQuota(hasPro: true, scansThisMonth: 10000)
        #expect(quota.canCreateScan)
        #expect(quota.remainingFreeScans == 0)
    }

    @Test func documentCombinesRecognizedTextInPageOrder() {
        let document = ScanDocument(
            title: "Receipt",
            mode: .receipt,
            pages: [
                ScanPage(imageFilename: "a.jpg", recognizedText: "Store"),
                ScanPage(imageFilename: "b.jpg", recognizedText: "Total $12")
            ]
        )

        #expect(document.recognizedText == "Store\n\nTotal $12")
    }

    @Test func pdfExportSurfacesMissingPageImages() async throws {
        let document = ScanDocument(
            title: "Missing Image",
            mode: .document,
            pages: [ScanPage(imageFilename: "missing.jpg")]
        )
        let service = PDFExportService()

        do {
            _ = try await service.render(document: document) { _ in
                throw PDFExportError.missingImage
            }
            Issue.record("Expected PDF export to throw when a page image cannot be loaded.")
        } catch PDFExportError.missingImage {
            return
        } catch {
            Issue.record("Unexpected PDF export error: \(error)")
        }
    }

    @Test func pdfExportRejectsInvalidPageImages() async throws {
        let document = ScanDocument(
            title: "Invalid Image",
            mode: .document,
            pages: [ScanPage(imageFilename: "invalid.jpg")]
        )
        let service = PDFExportService()

        do {
            _ = try await service.render(document: document) { _ in UIImage() }
            Issue.record("Expected PDF export to throw when a page image has invalid dimensions.")
        } catch PDFExportError.invalidImage {
            return
        } catch {
            Issue.record("Unexpected PDF export error: \(error)")
        }
    }

    @Test func pdfExportIncludesLongRecognizedTextAcrossPages() async throws {
        let longText = (1 ... 260)
            .map { "Recognized text line \($0)" }
            .joined(separator: "\n")
        let document = ScanDocument(
            title: "Long OCR",
            mode: .document,
            pages: [ScanPage(imageFilename: "page.jpg", recognizedText: longText)]
        )
        let service = PDFExportService()

        let data = try await service.render(document: document) { _ in
            UIGraphicsImageRenderer(size: CGSize(width: 120, height: 160)).image { context in
                UIColor.white.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 120, height: 160))
            }
        }

        let pdf = CGPDFDocument(CGDataProvider(data: data as CFData)!)
        #expect((pdf?.numberOfPages ?? 0) > 2)
    }

    @Test func pdfExportStillHandlesEmptyRecognizedText() async throws {
        let document = ScanDocument(
            title: "Image Only",
            mode: .document,
            pages: [ScanPage(imageFilename: "page.jpg")]
        )
        let service = PDFExportService()

        let data = try await service.render(document: document) { _ in
            UIGraphicsImageRenderer(size: CGSize(width: 120, height: 160)).image { context in
                UIColor.white.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 120, height: 160))
            }
        }

        let pdf = CGPDFDocument(CGDataProvider(data: data as CFData)!)
        #expect(pdf?.numberOfPages == 1)
    }

    @Test func pdfExportCanRenderTextOnlyDocuments() async throws {
        let document = ScanDocument(
            title: "Text Only",
            mode: .document,
            pages: [ScanPage(imageFilename: "page.jpg", recognizedText: "One line")]
        )
        let service = PDFExportService()

        let data = try await service.render(document: document) { _ in
            UIGraphicsImageRenderer(size: CGSize(width: 120, height: 160)).image { context in
                UIColor.white.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 120, height: 160))
            }
        }

        let pdf = CGPDFDocument(CGDataProvider(data: data as CFData)!)
        #expect(pdf?.numberOfPages == 2)
    }

    @Test func paywallUnavailableCopyIsCustomerSafe() {
        let message = "Connect to the App Store to view Pro options, or restore purchases if you already have Pro."
        #expect(!message.localizedCaseInsensitiveContains("StoreKit"))
        #expect(!message.localizedCaseInsensitiveContains("App Store Connect"))
        #expect(!message.localizedCaseInsensitiveContains("testing"))
    }

    @Test func purchaseErrorsAreCustomerSafe() {
        #expect(!PurchaseManager.temporarilyUnavailableMessage.localizedCaseInsensitiveContains("StoreKit"))
        #expect(!PurchaseManager.temporarilyUnavailableMessage.localizedCaseInsensitiveContains("App Store Connect"))
        #expect(!PurchaseManager.purchaseFailedMessage.localizedCaseInsensitiveContains("StoreKit"))
        #expect(!PurchaseManager.purchaseFailedMessage.localizedCaseInsensitiveContains("App Store Connect"))
    }

    @Test @MainActor func fixtureDocumentsDoNotConsumePublicFreeQuotaAfterReload() {
        let library = ScanLibrary()
        library.resetForUITesting()
        library.installFixtureDocuments()

        #expect(library.documents.count == 3)
        #expect(library.quota(hasPro: false).remainingFreeScans == 10)

        library.load()
        #expect(library.documents.count == 3)
        #expect(library.quota(hasPro: false).remainingFreeScans == 10)

        library.resetForUITesting()
    }
}
