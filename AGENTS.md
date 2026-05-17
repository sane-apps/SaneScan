# SaneScan Agent Instructions

Use plain English. Keep it short and direct.

## Read First

1. `README.md`
2. `DEVELOPMENT.md`
3. `ARCHITECTURE.md`
4. `SESSION_HANDOFF.md`

## Project Rules

- SaneScan is an iOS-first App Store app.
- Keep customer scan data local by default.
- Do not add analytics, tracking, cloud sync, or account requirements without an explicit product decision.
- Camera and Photos permissions are feature-scoped: request them only when the user starts scanning or importing.
- Use `./scripts/SaneMaster.rb verify` for project verification when the wrapper supports the app.
- Build and runtime verification should happen on the Mac Mini unless the user explicitly approves local fallback.

## Product Direction

The wedge is a private scanner for old photos and documents:

- Photo import and cleanup for family archive scans.
- VisionKit document scanning for receipts, forms, and papers.
- Vision OCR for searchable text.
- PDF export with images and recognized text.
- StoreKit Pro upgrade for ongoing sales.
