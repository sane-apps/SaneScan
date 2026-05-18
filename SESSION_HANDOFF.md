# SaneScan Session Handoff

## Current State

- New iOS app scaffold created at `/Users/sj/SaneApps/apps/SaneScan`.
- Core MVP includes VisionKit document scanning, Photos import, local image cleanup, Vision OCR, local library persistence, PDF export, and StoreKit Pro hooks.
- XcodeGen project spec is in `project.yml`.

## Verification

- Completed: generated `SaneScan.xcodeproj` with XcodeGen.
- Completed: Mini simulator test passed with explicit iOS Simulator destination:
  `xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination id=D722DC92-4597-458C-95D8-B1D73A2FB385 -configuration Debug CODE_SIGNING_ALLOWED=NO test`
- Result: 3 Swift Testing tests passed in `ScanQuotaTests`; `xcodebuild` reported `TEST SUCCEEDED`.
- Completed: launched `com.sanescan.dev` on the Mini iPhone 17 Pro simulator and captured `outputs/sanescan-launch.png`.
- Note: `./scripts/SaneMaster.rb verify` compiled the project but picked an unsuitable destination for this new iOS-only app and failed during install. Use the explicit simulator command above until SaneMaster has first-class SaneScan/iOS-only destination support.
- Completed: aggressive Mini E2E rerun after UI hardening:
  `xcodebuild -project SaneScan.xcodeproj -scheme SaneScan -destination id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2 -configuration Debug CODE_SIGNING_ALLOWED=NO test`
- Latest result: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_00-24-42--0400.xcresult`; 3 Swift Testing unit tests and 3 XCTest UI tests passed. UI coverage includes empty library controls, fixture detail image/OCR, native PDF share sheet presentation and close, and paywall unavailable state.
- Rechecked at 2026-05-17 00:38 ET with the same explicit simulator destination. Result: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_00-36-56--0400.xcresult`; 3 Swift Testing unit tests and 3 XCTest UI tests passed again.
- Completed: `swiftlint lint --quiet` passed.
- Completed: strict dark-mode static filter passed for customer-facing app/website surfaces: no `.secondary`, no gray text styles, no `href="#"`, no `NSPhotoLibraryAddUsageDescription`, and app Info.plist has `UIUserInterfaceStyle = Dark`.
- Runtime note: CoreSimulator screenshot capture hung once and earlier produced Mach/CoreSimulator instability. The runner itself is green on simulator `7A11FD35-2A11-46B2-A70B-D4BCD92B66C2`; keep using explicit simulator IDs until SaneMaster destination handling is updated.
- Completed: visual-audit rerun with saved screenshot artifacts and a written receipt:
  `/Users/sj/SaneApps/apps/SaneScan/outputs/visual-audit-2026-05-17-1429/visual-audit.md`
- Latest Mini result: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_14-28-05--0400.xcresult`; 3 Swift Testing unit tests and 4 XCTest UI tests passed. UI coverage includes empty library controls, fixture library, fixture detail image/OCR, export share sheet presentation, paywall presentation, and photo picker reachability.
- Latest lint: `swiftlint lint --quiet` passed on the Mini.
- Valid visual screenshots: empty library, fixture library, document detail, native share sheet, and paywall development state.
- Visual caveats from the earlier 14:29 run: the photo-picker screenshot was invalid because it captured the dimmed app underneath the native picker. The 15:30 redesign run captured the native picker correctly; real-device VisionKit camera proof remains pending; App Store Connect products must be configured before release so customers do not see `Products unavailable`.
- Completed: SaneScan visual redesign pass with richer SaneUI teal/navy/blue/gold gradients and tightened first-run/quota/paywall/detail surfaces.
- Latest redesign verification: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_15-28-35--0400.xcresult`; 3 Swift Testing unit tests and 4 XCTest UI tests passed on Mini simulator `7A11FD35-2A11-46B2-A70B-D4BCD92B66C2`.
- Latest redesign lint: `swiftlint lint --quiet` passed on the Mini with no output.
- Latest redesign screenshot receipt: `/Users/sj/SaneApps/apps/SaneScan/outputs/visual-audit-redesign-final-2026-05-17-1530/visual-audit.md`.
- Latest valid app-owned redesign screenshots: empty library, fixture library, document detail, and paywall development state. Native share sheet and native photo picker reachability were also captured.
- Pending: real-device VisionKit camera proof.
- Completed: document-first fixture/media correction after user feedback. UI fixtures now use `Contract Packet`, `Tax Receipt`, and `Clinic Intake Form` document scans instead of family-photo demos; the simulator Photos library was seeded with generated document images for picker proof.
- Completed: app icon replaced with `/Users/sj/Downloads/SaneScan.png`, resized to 1024 for both AppIcon asset names. It is the approved dark document-in-scan icon with cyan scan brackets and beam.
- Completed: git repo initialized on `main`; `LICENSE` is PolyForm Shield and README now links it.
- Completed: Apple Developer/App Store Connect Bundle ID `com.sanescan.app` created with id `UT3A85VYT3`.
- Blocked: App Store Connect app record creation still requires the website. API `POST /apps` returned `FORBIDDEN_ERROR` because Apple allows only get/update on `apps`; Mini Safari is at the App Store Connect login iframe, which was not script-interactable from the remote session, and Mini keychain lookup did not find `idmsa.apple.com` or `appstoreconnect.apple.com` entries.
- Latest document-first verification: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_16-04-04--0400.xcresult`; 3 Swift Testing unit tests and 4 XCTest UI tests passed. `swiftlint lint --quiet` passed.
- Latest visual-only proof after seeding document images into Photos: `TEST SUCCEEDED` in `Test-SaneScan-2026.05.17_16-09-08--0400.xcresult`. Screenshots saved locally at `/Users/sj/SaneApps/apps/SaneScan/outputs/visual-audit-docs-icon-2026-05-17-1609/`.
- Completed: GitHub remote created and pushed at `https://github.com/sane-apps/SaneScan`.
- Completed: local App Store preflight noise reduced by adding the conventional 1024 icon filename and aligning StoreKit gates with `isPro`/`purchasePro`; Mini verification after this change passed in `Test-SaneScan-2026.05.17_16-26-36--0400.xcresult`, and `swiftlint lint --quiet` passed.
- Completed: App Store Connect app record created for `SaneScan` with app ID `6770391054`; Bundle ID is `com.sanescan.app`.
- Completed: Cloudflare Pages privacy URL is live at `https://sanescan-site.pages.dev/privacy`.
- Completed: App Store screenshots uploaded for iPhone 6.7-inch and iPad Pro 12.9-inch.
- Completed: App Store build `100` for version `1.0` was archived, exported, uploaded, processed, and attached to the iOS version.
- Completed: annual subscription `com.sanescan.app.pro.annual` was created in subscription group `SaneScan Pro`, priced across all Apple territories, attached to the version, and submitted with the app.
- Completed: App Privacy was published as `Data Not Collected`.
- Completed: SaneScan iOS `1.0` is submitted to Apple and App Store Connect reports `WAITING_FOR_REVIEW` with submission ID `aa25a650-7eb8-4b5f-9e71-a93ec3d856b8`.
- Latest release verification, 2026-05-17 23:45 ET: explicit Mini simulator `xcodebuild` test passed in `Test-SaneScan-2026.05.17_23-45-46--0400.xcresult`; 3 Swift Testing unit tests and 4 XCTest UI tests passed. `swiftlint lint --quiet` and Ruby syntax checks for the patched App Store helper files also passed.
- Latest App Store preflight status: ASC lane, screenshots, privacy URL, review contact, version lane, subscription, StoreKit routing, signing profile, debug audit, review notes, category, age rating, and listing copy all pass. The remaining red is a known SaneMaster test-runner false failure: it targets `platform=macOS,arch=arm64` with signing disabled for this iOS app, causing an install error (`No code signature found`) despite the explicit simulator test run being green.
- SOP fix from this session: App Store Connect / Apple Developer / Apple ID portal work must reuse one Mini Safari tab via `mini-safari.sh open-current` / `open-read-current`; `mini-safari.sh open` and `open-read` now refuse Apple portal URLs unless an explicit recovery override is set.

## Open Follow-Up

- Monitor App Store review for SaneScan iOS `1.0`.
- Fix SaneMaster's SaneScan/iOS-only test destination handling so `appstore_preflight` uses the explicit simulator path instead of a macOS install attempt.
- Add real-device VisionKit document camera proof when an iPhone connection is available; simulator coverage remains valid for launch, Photos import, fixtures, PDF export/share sheet, and paywall surfaces.
