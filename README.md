# SaneScan

SaneScan is a private iPhone and iPad scanner for photos, receipts, and documents.

It uses Apple's VisionKit scanner, Vision OCR, local image cleanup, and PDF export. Scans stay on the device unless the user explicitly shares or exports them.

## Features

- Scan documents with the system VisionKit scanner.
- Import old photos from Photos.
- Clean up scans with local Core Image adjustments.
- Run local OCR with Apple's Vision framework.
- Export scanned pages and recognized text as a PDF through the system share sheet.
- Free monthly quota with StoreKit Pro hooks for unlimited scanning.

## Privacy

SaneScan does not require an account, does not track users, and does not upload scan content. Camera and Photos access are requested only when the user starts a scan or import.

Public privacy page: `https://sanescan.com/privacy.html`

## License

SaneScan is released under the PolyForm Shield License. See [LICENSE](LICENSE).

## Build

```bash
xcodegen generate
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

For SaneApps work, run builds and tests on the Mac Mini when available.
