import Testing
@testable import SaneScan

struct ScanQuotaTests {
    @Test func freeQuotaAllowsTenMonthlyScans() {
        #expect(ScanQuota(hasPro: false, scansThisMonth: 0).canCreateScan)
        #expect(ScanQuota(hasPro: false, scansThisMonth: 9).canCreateScan)
        #expect(!ScanQuota(hasPro: false, scansThisMonth: 10).canCreateScan)
    }

    @Test func proQuotaAllowsUnlimitedScans() {
        let quota = ScanQuota(hasPro: true, scansThisMonth: 10_000)
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
}
