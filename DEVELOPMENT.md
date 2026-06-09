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

## Product Quality Gate

SaneScan opts into the shared professional product-quality checklist in
`Tests/CustomerUIActions.yml`:

```bash
ruby scripts/customer_ui_action_sweep.rb
./scripts/SaneMaster.rb customer_ui_contract --json --no-exit
ruby ../../infra/SaneProcess/scripts/appstore_public_screenshot_audit.rb \
  --project-root /Users/stephansmac/SaneApps/apps/SaneScan --country us
```

The checklist has 30+ hard questions across product fit, first run, core
workflow, visual proof, marketing parity, monetization, accessibility,
privacy/trust, error recovery, performance, App Store readiness, and funnel
telemetry. Release is blocked when any product-quality item is `failed` or
`unknown`.

Current known blockers from the 2026-06-07 sweep:

- Real-device VisionKit scanner proof is still pending.
- StoreKit transaction proof still needs a real Xcode StoreKit,
  sandbox/TestFlight, or attached-device purchase/cancel/failure/restore run.

Verified fixes from the 2026-06-07 remediation:

- Local screenshot asset order leads with a real document-detail/OCR/PDF screen.
- Local paywall screenshot shows the approved annual product only.
- Large Dynamic Type, failure-recovery, cold-launch/performance, accessibility
  label/order, and App Store funnel event schema checks are covered by tests or
  source receipts.
- The live public App Store screenshot parity audit passes and writes
  `outputs/appstore-public-audit`.

Apple rejected attempts to delete/recreate live App Store screenshots on version
`1.0` after submission. Updating public screenshots requires a new editable App
Store version.

Latest Mini receipt, 2026-05-18 02:58 ET:

```bash
xcodebuild -project SaneScan.xcodeproj -scheme SaneScan \
  -destination "id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2" \
  -configuration Debug CODE_SIGNING_ALLOWED=NO test
```

Result: `TEST SUCCEEDED`; 4 Swift Testing unit tests and 4 XCTest UI tests passed in `Test-SaneScan-2026.05.18_02-57-54--0400.xcresult`. The added unit test verifies PDF export surfaces missing page-image failures instead of silently producing blank PDF pages. `swiftlint lint --quiet` and `swiftformat --lint --trailing-commas never` passed on the Mini.

## StoreKit

Product IDs are defined in `PurchaseManager`:

- `com.sanescan.app.pro.yearly6`

Only the approved annual product is active in the app and in
`iOS/SaneScan.storekit`.

Current App Store Connect state, 2026-06-07:

- Bundle ID `com.sanescan.app` exists in Apple Developer/App Store Connect as `UT3A85VYT3`.
- App Store Connect app ID is `6770391054`.
- App Store version `1.0` reports `READY_FOR_SALE`; submission ID `528b035a-b097-445f-834b-257d4e059720`.
- Public US App Store URL `https://apps.apple.com/us/app/sanescan/id6770391054` returns HTTP 200.
- The annual subscription product is `com.sanescan.app.pro.yearly6` and is approved.
- Local/public privacy policy copy has been updated for limited aggregate
  purchase-flow diagnostics; App Store Connect App Privacy metadata should be
  reviewed before the next editable submission.
- GitHub remote exists at `https://github.com/sane-apps/SaneScan`.
- Latest Mini release proof: explicit iPhone simulator `xcodebuild` passed on 2026-05-18 after the top-right screenshot artifact fix and final asset refresh; exit code 0.
- Latest visual proof: `outputs/visual-audit-final16-2026-05-18/contact-sheet.png`, `outputs/visual-audit-final17-2026-05-18/marketing-assets-contact-sheet.png`, and `outputs/website-audit-2026-05-18/final17/`.

Known tooling note: SaneMaster now supports iOS-only destinations for SaneScan,
but product-quality review blockers intentionally prevent treating the current
proof set as fully release-clear.
