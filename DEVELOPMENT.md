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

Latest Mini receipt, 2026-05-18 02:58 ET:

```bash
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan \
  -destination "id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2" \
  -configuration Debug CODE_SIGNING_ALLOWED=NO test
```

Result: `TEST SUCCEEDED`; 4 Swift Testing unit tests and 4 XCTest UI tests passed in `Test-SaneScan-2026.05.18_02-57-54--0400.xcresult`. The added unit test verifies PDF export surfaces missing page-image failures instead of silently producing blank PDF pages. `swiftlint lint --quiet` and `swiftformat --lint --trailing-commas never` passed on the Mini.

## StoreKit

Product IDs are defined in `PurchaseManager`:

- `com.sanescan.app.pro.yearly3`
- `com.sanescan.app.pro.lifetime`

These must be created in App Store Connect before public sale.

Current App Store Connect state, 2026-05-18:

- Bundle ID `com.sanescan.app` exists in Apple Developer/App Store Connect as `UT3A85VYT3`.
- App Store Connect app ID is `6770391054`.
- App Store version `1.0` is submitted and reports `WAITING_FOR_REVIEW`; submission ID `ca47e197-7e12-477b-9de9-85387507f142`.
- Build `100` is attached to version `1.0`.
- The annual subscription product is `com.sanescan.app.pro.yearly3` and is submitted with the version.
- App Privacy is published as `Data Not Collected`.
- GitHub remote exists at `https://github.com/sane-apps/SaneScan`.
- Latest Mini release proof: explicit iPhone simulator `xcodebuild` passed on 2026-05-18 after the top-right screenshot artifact fix and final asset refresh; exit code 0.
- Latest visual proof: `outputs/visual-audit-final16-2026-05-18/contact-sheet.png`, `outputs/visual-audit-final17-2026-05-18/marketing-assets-contact-sheet.png`, and `outputs/website-audit-2026-05-18/final17/`.

Known tooling issue: `./scripts/SaneMaster.rb appstore_preflight` currently runs the iOS app against `platform=macOS,arch=arm64` with signing disabled and fails install with `No code signature found`. Use the explicit iOS simulator command above as the canonical test proof until SaneMaster gets first-class iOS-only destination handling for SaneScan.
