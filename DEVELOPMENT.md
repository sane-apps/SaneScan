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

Latest Mini receipt, 2026-05-17 16:05 ET:

```bash
SANESCAN_SCREENSHOT_DIR=/tmp/sanescan-visual-audit \
  xcodebuild -project SaneScan.xcodeproj -scheme SaneScan \
  -destination "id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2" \
  -configuration Debug CODE_SIGNING_ALLOWED=NO test
```

Result: `TEST SUCCEEDED`; 3 Swift Testing unit tests and 4 XCTest UI tests passed. `swiftlint lint --quiet` also passed. Visual screenshots cover the empty library, document-seeded Photos picker, document fixture library, document detail/OCR, native share sheet, and paywall unavailable state.

## StoreKit

Product IDs are defined in `PurchaseManager`:

- `com.sanescan.app.pro.yearly`
- `com.sanescan.app.pro.lifetime`

These must be created in App Store Connect before public sale.

Current App Store Connect state, 2026-05-17:

- Bundle ID `com.sanescan.app` exists in Apple Developer/App Store Connect as `UT3A85VYT3`.
- The App Store app record is not created yet. The App Store Connect API returned `FORBIDDEN_ERROR` because the `apps` resource does not allow `CREATE`; it allows only get/update operations.
- The Mini Safari session is stopped at App Store Connect login. Remote JavaScript and Accessibility can see the Apple sign-in iframe but not interact with the iframe controls, and the Mini keychain did not expose saved entries for `idmsa.apple.com` or `appstoreconnect.apple.com`.
