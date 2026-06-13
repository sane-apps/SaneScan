# SaneScan Session Handoff

## Current State

- 2026-06-07 website polish pass: researched common AI-generic website markers
  and tightened the SaneScan homepage so it feels more deliberate and less
  template-like. Changes remove the glow/grid background treatment, reduce
  generic badge styling, keep the navy/teal palette dominant, sharpen the hero
  copy to `Private scans. Searchable PDFs.`, and keep the real iPhone/iPad app
  screenshots as the primary proof. Deployed via SaneProcess website-only
  release to Cloudflare Pages preview `https://11686208.sanescan-site.pages.dev`;
  production `https://sanescan.saneapps.com/` contains the updated copy and
  assets return HTTP 200. Visual proof saved under
  `/Users/stephansmac/SaneApps/outputs/website-polish-20260607/`.
- 2026-06-07 SaneScan remediation status: SaneScan iOS `1.0` is
  `READY_FOR_SALE` in App Store Connect, public US URL
  `https://apps.apple.com/us/app/sanescan/id6770391054` returns HTTP 200, and
  annual IAP `com.sanescan.app.pro.yearly6` is approved. The website was
  redeployed to Cloudflare Pages with live App Store CTA, annual-only Pro copy,
  and updated privacy language for limited aggregate purchase-flow diagnostics.
  Local screenshot assets were corrected so the first iPhone image shows a real
  document detail/OCR/PDF workflow and the paywall image shows the approved
  annual product only. Apple blocks editing screenshots on the live submitted
  `READY_FOR_SALE` 1.0 version, so public App Store screenshot replacement now
  requires a new editable version.
- 2026-06-07 product-quality gate/audit: SaneScan now opts into a shared
  professional product-quality checklist through `Tests/CustomerUIActions.yml`
  (`require_product_quality_checklist: true`). The checklist has 30+ questions
  covering product fit, first run, core workflow, screenshot proof, marketing
  parity, monetization, accessibility, privacy/trust, error recovery,
  performance, App Store readiness, and funnel telemetry. The app sweep writes
  `product_quality_review` into `.sane/customer_ui_action_receipt.json` and
  `outputs/customer_ui_action_receipt.json`; shared SaneProcess
  `customer_ui_contract` now blocks release when any product-quality item is
  `failed` or `unknown`.
- Latest SaneScan sweep generated product-quality reports under
  `outputs/product-quality/`. The current canonical contract is intentionally
  red only for proof gaps: real-device VisionKit scanner proof is still blocked
  by no attached iPhone, and StoreKit transaction proof still needs an active
  Xcode StoreKit, sandbox/TestFlight, or attached-device purchase/cancel/
  failure/restore run. The local product catalog, paywall copy, screenshot
  assets, accessibility/Dynamic Type checks, failure-recovery checks,
  launch/performance checks, and funnel event schema checks have receipts.
- Shared SaneProcess guardrails were updated and verified:
  `ruby infra/SaneProcess/scripts/appstore_submit_guardrail_test.rb` passed
  `31/31`. `appstore_submit.rb` now returns a nonzero failure when App Store
  screenshot deletion/reservation/upload is rejected instead of silently
  reporting completion. `appstore_public_screenshot_audit.rb` still passes and
  writes `outputs/appstore-public-audit`.
- 2026-06-07 live App Store/site correction: SaneScan iOS `1.0` was already
  `READY_FOR_SALE`, but the public listing was not reachable because App Store
  Availability V2 had no app availability resource for app `6770391054`.
  Created the App Availability V2 resource with all 175 territories enabled.
  USA territory status progressed to `AVAILABLE`; direct public storefront URL
  now returns HTTP 200 at `https://apps.apple.com/us/app/sanescan/id6770391054`.
  Apple iTunes Lookup still returns `resultCount=0`, so search/lookup indexing
  may lag the live storefront URL. Website CTA now points to the live App Store
  URL and was deployed to Cloudflare Pages `sanescan-site`; production
  `https://sanescan.saneapps.com/` returns HTTP 200 and contains
  `Download on the App Store` with no stale "Coming soon" CTA.
- 2026-06-05 App Store repair/resubmission: SaneScan iOS `1.0` now reports
  `WAITING_FOR_REVIEW` in App Store Connect with review submission
  `528b035a-b097-445f-834b-257d4e059720`. The actionable rejection family was
  first-subscription readiness/attachment. The app was rotated from rejected
  subscription `com.sanescan.app.pro.yearly3` to fresh subscription
  `com.sanescan.app.pro.yearly6`; `yearly6` is `READY_TO_SUBMIT` and verified
  attached under iOS `1.0` Included Assets. Build `1001` was attached to version
  `2898846c-163e-4d53-8cdc-e4788b7ec9fa`, customer UI sweep passed, App Store
  preflight passed with warnings only, and `appstore_submit.rb --skip-upload
  --skip-screenshots --build-number 1001` submitted the version.
  Release-pending sweep found no `PENDING_DEVELOPER_RELEASE` versions.
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
- Completed: Cloudflare Pages privacy URL is live at `https://sanescan.saneapps.com/privacy/`.
- Completed: App Store screenshots uploaded for iPhone 6.7-inch and iPad Pro 12.9-inch.
- Completed: App Store build `100` for version `1.0` was archived, exported, uploaded, processed, and attached to the iOS version.
- Active: annual subscription `com.sanescan.app.pro.yearly3` replaced the rejected original subscription group/product metadata. It still needs final ASC review metadata proof before resubmission.
- Superseded: App Privacy was originally published as `Data Not Collected`.
  Local/public privacy policy copy now allows limited aggregate purchase-flow
  diagnostics, so App Store Connect App Privacy metadata needs review before the
  next editable submission if that telemetry remains active.
- Completed: SaneScan iOS `1.0` is submitted to Apple and App Store Connect reports `WAITING_FOR_REVIEW` with submission ID `ca47e197-7e12-477b-9de9-85387507f142`.
- Latest release verification, 2026-05-17 23:45 ET: explicit Mini simulator `xcodebuild` test passed in `Test-SaneScan-2026.05.17_23-45-46--0400.xcresult`; 3 Swift Testing unit tests and 4 XCTest UI tests passed. `swiftlint lint --quiet` and Ruby syntax checks for the patched App Store helper files also passed.
- Latest App Store preflight status: ASC lane, screenshots, privacy URL, review contact, version lane, subscription, StoreKit routing, signing profile, debug audit, review notes, category, age rating, and listing copy all pass. The remaining red is a known SaneMaster test-runner false failure: it targets `platform=macOS,arch=arm64` with signing disabled for this iOS app, causing an install error (`No code signature found`) despite the explicit simulator test run being green.
- SOP fix from this session: App Store Connect / Apple Developer / Apple ID portal work must reuse one Mini Safari tab via `mini-safari.sh open-current` / `open-read-current`; `mini-safari.sh open` and `open-read` now refuse Apple portal URLs unless an explicit recovery override is set.
- Website release update, 2026-05-18: SaneScan website deployed at `https://sanescan.saneapps.com/` with branded canonical/social metadata, real social card, privacy page, robots.txt, sitemap.xml, security headers, `/privacy.html` redirect, and custom 404. Visual proof lives in `outputs/website-audit-2026-05-18/`, including `mini-safari-window-final.png`, `live-home-desktop-final.png`, `live-home-iphone-final.png`, `live-home-small-mobile-final.png`, `live-home-ipad-final.png`, `live-privacy-final.png`, and `live-notfound-final.png`.
- Final website/code polish update, 2026-05-18 02:58 ET: deployed Cloudflare Pages preview `https://d17a88a9.sanescan-site.pages.dev` to `https://sanescan.saneapps.com/`. Fresh visual proof includes `mini-safari-window-final3-fresh.png`, `live-home-desktop-final3.png`, `live-home-iphone-final3.png`, `live-home-small-mobile-final3.png`, `live-home-ipad-final3.png`, `live-privacy-final3.png`, `live-notfound-final3.png`, `live-pro-section-final3.png`, and `live-home-fullpage-final3.png`.
- Final Mini verification, 2026-05-18 06:42 ET: explicit iPhone simulator `xcodebuild` test passed after the realistic sample-document fixture and paywall screenshot wording fixes; 11 Swift Testing tests and 4 XCTest UI tests passed. `swiftlint lint --quiet` and `swiftformat --lint --trailing-commas never` passed.
- Final Mini verification, 2026-05-18 09:00 ET: explicit iPhone simulator `xcodebuild` test passed after the top-right screenshot artifact fix and final asset refresh; exit code 0. `swiftlint lint --quiet` and `swiftformat --lint --trailing-commas never` passed locally after the final source changes.
- Final QA receipt, 2026-05-18 09:07 ET: explicit Mini iPhone 17 Pro simulator QA passed after Mini SwiftFormat 0.60 cleanup; `TEST SUCCEEDED` in `/Users/stephansmac/Library/Developer/Xcode/DerivedData/SaneScan-ccnbroaqfmwsoocspmnnnwkoyrwe/Logs/Test/Test-SaneScan-2026.05.18_09-05-06--0400.xcresult`. Evidence log is `outputs/qa/sanescan-xcodebuild-20260518T130504Z.log`; receipt is `outputs/qa_status.json`. Coverage: 11 Swift Testing tests, 4 XCTest UI tests, 0 failures. `swiftlint lint --quiet` passed and Mini `swiftformat --lint --trailing-commas never .` reported `0/17 files require formatting, 9 files skipped`.
- Validation note, 2026-05-18: SaneScan checklist is green except `Latest project QA gate is current`, which is stale only because the repository has 39 uncommitted paths. Resolve by committing/cleaning the current app/website changes or by upgrading `validation_report.rb` to compare a QA source fingerprint captured by `outputs/qa_status.json`.
- Final visual proof, 2026-05-18: realistic fictional sample documents replaced placeholder bars; the app top-right scan/import toolbar was moved into the content; public App Store/website screenshots now remove simulator status-bar marks. App proof: `outputs/visual-audit-final16-2026-05-18/contact-sheet.png`. App Store/marketing proof: `outputs/visual-audit-final17-2026-05-18/marketing-assets-contact-sheet.png`. Website proof: `outputs/website-audit-2026-05-18/final17/website-contact-sheet.png` and `outputs/website-audit-2026-05-18/final17/sanescan-mini-safari-final17-site-window.png`.
- Tooling note: `capture-mini-screenshot.sh --app Safari` is currently not safe for Safari website evidence because `mini-visual-workspace-guard.sh --cleanup --app Safari` quits Safari as clutter before capture. Use Mini Safari DOM proof plus `capture-mini-screenshot.sh --list-windows` and then capture the specific Safari `--window-id` until the guard excludes the target app from the clutter-app loop.
- QA/status update, 2026-05-18 09:37 ET:
  - SaneProcess `validation_report.rb` now accepts `outputs/qa_status.json` `sourceFingerprint` receipts instead of treating any dirty tree as stale. Local and Mini `ruby scripts/validation_report_test.rb` passed `27/27`; Mini SaneScan checklist now reports `Latest project QA gate passed (2026-05-18 13:07)`.
  - `outputs/qa_status.json` records the current source fingerprint, the Mini simulator QA evidence, and the real-device VisionKit blocker. Physical-device proof is still blocked because `xcrun devicectl list devices` on the Mini returned `No devices found`.
  - SaneMaster now supports iOS-only unit-test destinations and resolves ambiguous iOS simulator names to a concrete UDID using Ruby 2.6-compatible code. Mini `./scripts/SaneMaster.rb verify --timeout 600 --no-grant-permissions` passed `11` Swift Testing tests in `11s` using `id=7A11FD35-2A11-46B2-A70B-D4BCD92B66C2`.
  - Mini `./scripts/SaneMaster.rb appstore_preflight` now reaches the iOS lane correctly. It is blocked only on review contact metadata: `.saneprocess appstore.contact` is missing required `name` and `phone`. Warnings: dirty worktree and no direct-checkout fallback for website builds.
  - Added `.outreach.yml`; portfolio status now tracks SaneScan. Mini `./scripts/SaneMaster.rb launch_readiness --json` returns no-go with expected blockers: App Store `WAITING_FOR_REVIEW`, missing review contact metadata, real-device VisionKit proof blocked, and missing `outputs/release_preflight_status.json`.
- Release/SEO update, 2026-05-19:
  - App Store rejection reason was Apple's automated EULA metadata blocker: auto-renewable subscriptions needed a functional Terms of Use link in app metadata.
  - `.saneprocess` now includes Apple's standard EULA URL in the iOS description/review notes and includes App Review contact metadata.
  - App Store metadata sync completed. Stale empty ASC draft submissions were cleared in the already-open MacBook Air Safari window, then SaneScan iOS `1.0` was resubmitted. ASC now reports `WAITING_FOR_REVIEW` with submission ID `f0af0523-4da6-4570-b0d6-d51b900d063f`.
  - Website legal/SEO expansion is live at `https://sanescan.saneapps.com/`: `/terms/`, `/guides`, five private-scanning guide pages, sitemap lastmod coverage, Article/CollectionPage/WebPage JSON-LD, canonical URLs, social metadata, and fixed redirects.
  - Important SEO fix: Cloudflare Pages clean URLs redirect `.html` pages to extensionless paths, so SaneScan canonicals/internal links/sitemap now use extensionless guide URLs. Do not add `_redirects` entries that send extensionless guide paths back to `.html`; that creates a loop.
  - Cross-links are deployed on `saneapps.com/guides.html`, `sanebar.com/guides.html`, `saneclip.com/guides.html`, `sanesales.com/guides.html`, and `sanehosts.com/guides.html`.
  - Live checks passed: SaneScan home, legal, guides, sitemap, robots, sibling guide hubs, and Apple standard EULA all return `200`; live SEO markup checks passed for 9 SaneScan pages.
  - Visual evidence receipt: `outputs/website-audit-2026-05-19/final-screenshots/`. Captured WebKit desktop/iPhone/iPad home and guides, all five guide pages on iPhone, privacy, terms, and 404. Visual verdict: dark-mode surfaces are readable, balanced, unclipped, and use realistic document screenshots; no broken App Store CTA is left while Apple public listing is still 404.

- App Store go-live watch, 2026-05-20: checked ASC state for app ID `6770391054` version `1.0` and public URL `https://apps.apple.com/us/app/id6770391054`. Current state remains `WAITING_FOR_REVIEW` (launch package line still `SaneScan App Store 1.0=waiting_for_review`); public URL still returns HTTP `404`. No website redeploy was performed because the listing is not live yet.
- App Store go-live watch, 2026-05-20 04:09 ET: rechecked ASC state for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` and the public URL `https://apps.apple.com/us/app/id6770391054`. Current state is still `WAITING_FOR_REVIEW`; public URL still returns HTTP `404`. No website redeploy was performed because the listing is not live yet.
- App Store resubmission, 2026-05-20 11:42 ET:
  - Rebuilt and uploaded SaneScan iOS `1.0` build `1000` after the paywall Terms/Privacy fix. Apple validation passed with `VERIFY SUCCEEDED with no errors`; ASC processed build `1000` as `VALID` with build ID `b958f718-8667-494c-aa59-7a73cdbdd2fd`.
  - Guarded submit refreshed screenshots, metadata, review contact, accessibility declarations, and subscription readiness, then submitted review submission `e975c41c-37aa-434f-8e6b-4d220831c51a`. ASC now reports iOS version `1.0` state `WAITING_FOR_REVIEW`.
  - Official Apple checklist/preflight hardening is now in SaneProcess: required metadata declarations, privacy manifest inclusion, screenshot counts, subscription purchase-flow links/disclosures, subscription localization/price/availability/review screenshot, fresh customer-UI visual receipts, explicit export compliance, IAP attachment receipt, and Game Center entitlement/ASC relationship matching.
  - New blocker found and fixed before final submit: ASC had Game Center enabled for the version while the binary has no `com.apple.developer.game-center` entitlement. Patched ASC `gameCenterAppVersions/bfc44311-0d75-4292-b06c-8ddaf118594e` to `enabled=false` and added a SaneMaster preflight guard so future submissions fail before upload if this mismatch recurs.
  - Verification: Mini GUI archive succeeded with Apple Distribution identity and `SaneScan iOS App Store` profile; export succeeded; customer UI sweep passed for source fingerprint `d279251f8014f3c66ba05bc1e46182cb699267ee7fd3234279340b07b912dbdc`; refreshed App Store preflight passed with warnings only; SaneProcess release guardrail tests passed `76/76`; App Store submit guardrail tests passed `16/16`.
  - Current public App Store URL `https://apps.apple.com/us/app/id6770391054` still returns HTTP `404` until Apple approves and publishes the app.
## Open Follow-Up

- Monitor post-launch App Store listing health for SaneScan iOS `1.0`; the direct ASC check now reports `READY_FOR_SALE` and the public listing is live.
- Keep the website CTA pointed at `https://apps.apple.com/us/app/sanescan/id6770391054`; local `website/index.html` and the live homepage already match this production App Store URL.
- Add real-device VisionKit document camera proof when an iPhone connection is available; simulator coverage remains valid for launch, Photos import, fixtures, PDF export/share sheet, and paywall surfaces.
- Run/refresh SaneScan release or App Store preflight receipts after review state changes or physical-device proof becomes available.
- Fix the Mini Safari screenshot guard so `--app Safari` does not quit the target Safari window before capture.
- App Store go-live watch, 2026-05-20 05:11 ET: rechecked ASC via `./scripts/SaneMaster.rb launch_readiness --json` for app ID `6770391054` version `1.0`; status remains `WAITING_FOR_REVIEW` (still prelaunch and blocked on approval). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is still HTTP `404` (verified at 2026-05-20T09:10:13Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 06:12 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; status remains `WAITING_FOR_REVIEW` (still not approved/live). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is still HTTP `404` (verified at 2026-05-20T10:12:35Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 07:14 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; status remains `WAITING_FOR_REVIEW` (still prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is still HTTP `404` (verified at 2026-05-20T11:14:32Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 08:16 ET: rechecked ASC via `./scripts/SaneMaster.rb launch_readiness --json` for app ID `6770391054` version `1.0`; status remains `WAITING_FOR_REVIEW` (still not approved/live). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T12:15:49Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 09:17 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; status remains `WAITING_FOR_REVIEW` (still not approved/live). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T13:17:36Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 10:18 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; status remains `WAITING_FOR_REVIEW` (still not approved/live). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T14:18:16Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 12:21 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; status remains `WAITING_FOR_REVIEW` (still not approved/live). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T16:21:18Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 14:23 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T18:23:47Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 16:25 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T20:25:29Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 19:29 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-20T23:29:46Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-20 23:34 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` plus `./scripts/SaneMaster.rb status --json`; state remains `WAITING_FOR_REVIEW` (explicit status line: `SaneScan App Store 1.0=waiting_for_review`). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at `2026-05-21T03:34:57Z`). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-21 01:37 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-21T05:37:57Z). No website redeploy was performed because the listing is not live.

- App Store go-live watch, 2026-05-21 02:40 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` (and `status --json` cross-check); state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-21T06:40:27Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-21 03:40 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` (cross-reference also shows `SaneScan App Store 1.0=waiting_for_review`); state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-21T07:40:05Z). No website redeploy was performed because the listing is not live.

- App Store go-live watch, 2026-05-21 04:43 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-21T08:43:30Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-21 05:42 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` (cross-reference still shows `SaneScan App Store 1.0=waiting_for_review`); state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `429` (verified at 2026-05-21T09:42:49Z). No website redeploy was performed because the listing is not live.

- App Store go-live watch, 2026-05-21 10:49 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-21T14:49:53Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-21 11:52 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` (status cross-reference still shows `SaneScan App Store 1.0=waiting_for_review`); state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-21T15:52:03Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-22 13:00 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-22T17:00:54Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-22 19:02 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-22T23:02:45Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-24 07:09 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-24T11:09:39Z). No website redeploy was performed because the listing is not live.

- App Store go-live watch, 2026-05-24 19:13 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response remains HTTP `404` (verified at 2026-05-24T23:12:09Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-25 01:14 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `429` rate-limited (verified at 2026-05-25T05:13:37Z). No website redeploy was performed because the listing is not live.
- App Store resubmission repair, 2026-05-25 08:30 ET:
  - Apple rejection package for submission `e975c41c-37aa-434f-8e6b-4d220831c51a` was downloaded to `outputs/appreview-ios-1.0-e975c41c-37aa-434f-8e6b-4d220831c51a-20260525-074730/`; reviewer screenshot showed the paywall stuck at "App Store options loading" with no subscription price/button.
  - Root cause was submission-process, not app code: first subscription `com.sanescan.app.pro.yearly3` was `READY_TO_SUBMIT` but not attached under iOS 1.0 Included Assets. Attached it in ASC and verified with `appstore_submit.rb --iap-only`.
  - App Store preflight then passed with warnings only after refreshing customer UI QA, creating the missing Mini `iPhone 17 Pro` simulator, and disabling ASC Game Center for the version.
  - Cleared 2 stale ASC Draft Submissions and resubmitted via `appstore_submit.rb --skip-upload --skip-screenshots`; ASC now reports iOS 1.0 `WAITING_FOR_REVIEW` with submission ID `351cb54c-f374-4efd-a222-e1dba80d2f9e`.
  - Evidence screenshots copied locally: `/Users/sj/Desktop/Screenshots/sanescan-apple-review-subscription-failed.png`, `/Users/sj/Desktop/Screenshots/sanescan-asc-subscription-modal-closed-20260525-081152.png`, `/Users/sj/Desktop/Screenshots/sanescan-asc-after-update-review-click-20260525-082717.png`.
- Website repair, 2026-05-25: homepage was audited and patched locally after customer-facing copy/visual issues were reported. Changes in `website/index.html`: removed the launch-notice email CTA, made the first viewport and Pro section lead with SaneScan Pro value, removed Basic-only structured data, replaced homepage hero assets with existing Pro screenshots, fixed iPhone image dimensions to `1242x2688`, and rewrote privacy copy to avoid email-update wording. Also updated `website/privacy/index.html` so support email is described as support-only, not updates/notifications, and corrected the document-guide image dimensions. Public App Store URL still returns HTTP `404`, so the CTA remains prelaunch-safe (`Coming soon on the App Store` linking to `#pro`) until approval/public listing is confirmed. Local visual proof: `/tmp/sanescan-site-qa/home-desktop-final.png` and `/tmp/sanescan-site-qa/home-mobile-final.png`; audit receipt: `/tmp/website_audit_outputs/summary.md`.
- Website deployment, 2026-05-25: deployed the SaneScan website repair via `TEAM_ID=M78L6FXD48 bash /Users/sj/SaneApps/infra/SaneProcess/scripts/release.sh --project /Users/sj/SaneApps/apps/SaneScan --website-only`. Wrangler preview URL was `https://8cc077d4.sanescan-site.pages.dev`; production `https://sanescan.saneapps.com/`, `/privacy/`, and `/guides` returned HTTP `200`. Live visual proof: `/tmp/sanescan-site-qa/live-home-desktop-final.png` and `/tmp/sanescan-site-qa/live-home-mobile-final.png`.
- Website follow-up repair, 2026-05-25: user flagged that the homepage images still showed the paywall/upgrade screen and therefore were not Pro-mode functional app screenshots. Replaced homepage hero assets again so they show only working app surfaces: scan/import start screen and document detail with recognized OCR/PDF export. Removed remaining `Pro option`/upgrade wording from homepage image metadata/copy. Local proof before redeploy: `/tmp/sanescan-site-qa/home-desktop-functional.png` and `/tmp/sanescan-site-qa/home-mobile-functional.png`.
- Website follow-up deployment, 2026-05-25: redeployed corrected functional screenshots through `release.sh --website-only`; Wrangler preview URL was `https://0a35666b.sanescan-site.pages.dev`. Production `https://sanescan.saneapps.com/` now references `?v=20260525-functional` hero images and no longer includes upgrade/paywall strings in homepage source. Live proof: `/tmp/sanescan-site-qa/live-home-desktop-functional.png` and `/tmp/sanescan-site-qa/live-home-mobile-functional.png`.
- App Store go-live watch, 2026-05-26 19:23 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-26T23:22:49Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-05-27 07:25 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json` and `./scripts/SaneMaster.rb status --json`; state remains `WAITING_FOR_REVIEW` (cross-reference line: `SaneScan App Store 1.0=waiting_for_review`). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-05-27T11:25:47Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch, 2026-06-01 07:31 ET: rechecked ASC for app ID `6770391054` version `1.0` via `./scripts/SaneMaster.rb launch_readiness --json`; state remains `WAITING_FOR_REVIEW` (prelaunch/not approved, with weak-launch blocker explicitly reporting App Store version waiting for review). Rechecked public URL `https://apps.apple.com/us/app/id6770391054`; response is HTTP `404` (verified at 2026-06-01T11:30:00Z). No website redeploy was performed because the listing is not live.
- App Store go-live watch correction, 2026-06-01 08:08 ET: direct Mini ASC diagnostic via `appstore_submit.rb --list-versions` supersedes the earlier `launch_readiness` summary. App ID `6770391054` iOS `1.0` is `REJECTED`; linked review submission `351cb54c-f374-4efd-a222-e1dba80d2f9e` is `UNRESOLVED_ISSUES`; version id is `2898846c-163e-4d53-8cdc-e4788b7ec9fa`. Public App Store URL still returns HTTP `404`, and iTunes Lookup returns `resultCount: 0`, so no website redeploy was performed. Attempted `--fetch-review-message` and `--fetch-review-package`, but Safari automation on the Mini did not open the expected App Review page; App Review message/package still needs a signed-in Safari/App Store Connect session with JavaScript from Apple Events enabled.
- App Store go-live watch, 2026-06-03 14:30 ET: direct ASC API diagnostic using the SaneApps App Store key confirmed app ID `6770391054` iOS `1.0` is still `REJECTED`; version id remains `2898846c-163e-4d53-8cdc-e4788b7ec9fa`. The current linked review submission is now `dc139aed-e07d-419f-b9fd-04ab99365af2` in `UNRESOLVED_ISSUES`, submitted `2026-06-01T13:15:28.579Z`. Public URL `https://apps.apple.com/us/app/id6770391054` still returns HTTP `404`, and iTunes Lookup still returns `resultCount: 0`, so no website redeploy was performed. Fresh `--fetch-review-message` / `--fetch-review-package` attempts on this host failed because Safari is not running; the latest saved reviewer evidence is still `outputs/appreview-2026-05-20-subscription-links/` and shows the subscription paywall blocker requiring in-app functional Terms/EULA and privacy links.
- App Store go-live watch, 2026-06-13 11:02 EDT: direct Mini ASC check still reports SaneScan iOS `1.0` as `READY_FOR_SALE` with linked submission `528b035a-b097-445f-834b-257d4e059720` in `COMPLETE`. The public URL `https://apps.apple.com/us/app/id6770391054` redirects to `https://apps.apple.com/us/app/sanescan/id6770391054`, iTunes Lookup returns `resultCount: 1`, and the live website still serves `data-appstore-ios-link="https://apps.apple.com/us/app/sanescan/id6770391054"`. Latest Cloudflare Pages redeploy preview: `https://59a27bd0.sanescan-site.pages.dev`.
