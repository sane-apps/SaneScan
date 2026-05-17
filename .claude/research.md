## SwiftUI Sheet Item Binding | Updated: 2026-05-17 | Status: verified | TTL: 90d

Apple documents `View.sheet(item:onDismiss:content:)` with the generic constraint `Item: Identifiable`. `URL` does not conform to `Identifiable`, so exported PDF sharing uses a small `SharedExport: Identifiable` wrapper instead of binding `URL?` directly to `sheet(item:)`.

Source: Apple Developer Documentation, `sheet(item:onDismiss:content:)`.

## VisionKit Document Scanning | Updated: 2026-05-17 | Status: verified | TTL: 90d

Apple documents `VNDocumentCameraViewController` as the system UI for scanning physical documents. The scan result includes page images and Apple describes PDF export from those images as an intended use.

Source: Apple Developer Documentation, `VNDocumentCameraViewController`.

## Vision OCR | Updated: 2026-05-17 | Status: verified | TTL: 90d

Apple documents `VNRecognizeTextRequest` as the Vision request for image text recognition. SaneScan uses accurate recognition, language correction, automatic language detection, and revision 3.

Source: Apple Developer Documentation, `VNRecognizeTextRequest`.
