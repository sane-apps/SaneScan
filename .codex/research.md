## VisionKit Document Scanning | Updated: 2026-05-17 | Status: verified | TTL: 90d

Apple documents `VNDocumentCameraViewController` as the system scanner UI for physical documents. The scan result includes page images suitable for PDF export. SaneScan uses this API for the document path and PhotosPicker for imported old photos.

## Vision OCR | Updated: 2026-05-17 | Status: verified | TTL: 90d

Apple documents `VNRecognizeTextRequest` as the Vision request for image text recognition. SaneScan uses accurate recognition, language correction, automatic language detection, and revision 3.

## SaneApps Reuse | Updated: 2026-05-17 | Status: verified | TTL: 90d

Best reuse candidates were SaneClip for OCR/iOS app structure and SaneVideo for actor-style OCR/PDF service boundaries. SaneScan uses those patterns without copying macOS/video-specific implementation details.

## SwiftUI Nested Sheet Export | Updated: 2026-05-17 | Status: verified | TTL: 90d

SaneScan's PDF export share sheet must be owned by `DocumentDetailView`, because the detail view itself is already presented as a sheet. Presenting the native share sheet from the parent sheet host made export presentation unreliable in UI tests. The fixed flow clears the exporting overlay state before assigning the `SharedExport` item for `sheet(item:)`.

## App Store Connect App And Subscription Setup | Updated: 2026-05-17 | Status: verified | TTL: 30d

Apple's App Store Connect API docs state that the Apps API manages existing apps and should not be used to create new apps; new apps must be created on the App Store Connect website. Apple's subscription docs state that auto-renewable subscriptions are created under a subscription group via `POST /v1/subscriptions`. SaneScan therefore needs a website-created app record first, then a subscription group and yearly subscription product.

## SaneScan App Store Submission | Updated: 2026-05-17 | Status: verified | TTL: 7d

SaneScan App Store Connect app ID `6770391054` has iOS version `1.0` submitted and reporting `WAITING_FOR_REVIEW`; submission ID `aa25a650-7eb8-4b5f-9e71-a93ec3d856b8`. Build `100` is attached. Annual subscription `com.sanescan.app.pro.annual` is submitted with the app. App Privacy is published as `Data Not Collected`. Remaining release follow-up is review monitoring, SaneMaster iOS-only destination handling, and real-device VisionKit proof when an iPhone connection is available.
