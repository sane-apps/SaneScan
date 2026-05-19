# SaneScan Security

## Supported Versions

Security fixes are shipped in the latest public App Store version of SaneScan.

## Security Model

SaneScan is a local-first iOS scanner:

- Scan images and OCR text are stored in the app container.
- OCR uses Apple's on-device Vision framework.
- PDF export uses local rendering and the system share sheet.
- The app does not run a customer-data server for scan contents.

SaneScan is not a secure vault. If you store sensitive documents, protect the device with a passcode, Face ID, or Touch ID and use the normal iOS device security features.

## Reporting A Vulnerability

Email security or privacy concerns to hi@saneapps.com.

Please do not include sensitive personal documents in a public GitHub issue. If a report needs screenshots, sample scans, or logs, send them by email and redact anything private first.

## Scope

Useful reports include:

- Scan contents being uploaded unexpectedly
- Permissions requested before the user starts the related feature
- Sensitive data written outside the app container
- Purchase or entitlement bypasses
- Crashes caused by malformed imported images or PDFs

Out of scope:

- Issues requiring a jailbroken device
- Social engineering
- Denial-of-service reports without a practical user impact
