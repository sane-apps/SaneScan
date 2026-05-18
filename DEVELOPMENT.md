# SaneScan Development

## Requirements

- Xcode 16+
- XcodeGen
- iOS 17 simulator or device

## Commands

```bash
xcodegen generate
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Verification

Use the Mac Mini for canonical SaneApps build and simulator proof:

```bash
ssh mini 'cd ~/SaneApps/apps/SaneScan && xcodegen generate && xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination "platform=iOS Simulator,name=iPhone 17 Pro" test'
```

If the simulator name changes, run:

```bash
ssh mini 'xcrun simctl list devices available'
```

## Testing Notes

- Unit tests live in `Tests/`.
- UI tests live in `UITests/` and cover the empty library, fixture library detail, native PDF share sheet, and paywall unavailable state.
- UI/runtime camera proof needs a real device because `VNDocumentCameraViewController` is not available on all simulators.
- Simulator proof should still cover launch, Photos import UI, library display, paywall UI, PDF export code paths where possible.

Latest Mini receipt, 2026-05-17 23:45 ET:

```bash
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan \
  -destination "id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2" \
  -configuration Debug CODE_SIGNING_ALLOWED=NO test
```

Result: `TEST SUCCEEDED`; 3 Swift Testing unit tests and 4 XCTest UI tests passed in `Test-SaneScan-2026.05.17_23-45-46--0400.xcresult`. `swiftlint lint --quiet` also passed, and Ruby syntax checks passed for the patched App Store helper files. Visual screenshots cover the empty library, document-seeded Photos picker, document fixture library, document detail/OCR, native share sheet, and paywall unavailable state.

## StoreKit

Product IDs are defined in `PurchaseManager`:

- `com.sanescan.app.pro.annual`
- `com.sanescan.app.pro.lifetime`

These must be created in App Store Connect before public sale.

Current App Store Connect state, 2026-05-17:

- Bundle ID `com.sanescan.app` exists in Apple Developer/App Store Connect as `UT3A85VYT3`.
- App Store Connect app ID is `6770391054`.
- App Store version `1.0` is submitted and reports `WAITING_FOR_REVIEW`; submission ID `aa25a650-7eb8-4b5f-9e71-a93ec3d856b8`.
- Build `100` is attached to version `1.0`.
- The annual subscription product is `com.sanescan.app.pro.annual` and is submitted with the version.
- App Privacy is published as `Data Not Collected`.
- GitHub remote exists at `https://github.com/sane-apps/SaneScan`.

Known tooling issue: `./scripts/SaneMaster.rb appstore_preflight` currently runs the iOS app against `platform=macOS,arch=arm64` with signing disabled and fails install with `No code signature found`. Use the explicit iOS simulator command above as the canonical test proof until SaneMaster gets first-class iOS-only destination handling for SaneScan.
