# SaneScan

SaneScan is a private iPhone and iPad scanner for photos, receipts, and documents.

It uses Apple's VisionKit scanner, Vision OCR, local image cleanup, and PDF export. Scans stay on the device unless the user explicitly shares or exports them.

Public site: https://sanescan.saneapps.com

## Features

- Scan documents with the system VisionKit scanner.
- Import old photos from Photos.
- Clean up scans with local Core Image adjustments.
- Run local OCR with Apple's Vision framework.
- Export scanned pages and recognized text as a PDF through the system share sheet.
- Free monthly quota with StoreKit Pro hooks for unlimited scanning.

## Privacy

SaneScan does not require an account, does not track users, and does not upload scan content. Camera and Photos access are requested only when the user starts a scan or import.

Details:

- [Privacy policy](PRIVACY.md)
- [Security policy](SECURITY.md)
- Public privacy page: https://sanescan.saneapps.com/privacy/

## License

SaneScan is public, auditable code under the PolyForm Shield License. Personal use and experimentation are allowed; commercial use has restrictions. See [LICENSE](LICENSE).

## Build

```bash
./scripts/SaneMaster.rb verify
./scripts/SaneMaster.rb lint
```

For targeted iOS simulator debugging, use the explicit Mini simulator command documented in `DEVELOPMENT.md` until SaneMaster has first-class SaneScan destination handling.
