import UIKit
import XCTest

final class SaneScanUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testEmptyLibraryPrimarySurfaces() {
        launch(reset: true)

        XCTAssertTrue(app.staticTexts["SaneScan"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["scan-button"].exists)
        XCTAssertTrue(app.buttons["import-button"].exists)
    }

    func testFixtureLibraryDetailContent() {
        launch(reset: true, fixtures: true)

        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["10 free scans left"].exists)
        XCTAssertTrue(app.buttons["Contract Packet"].exists)
        XCTAssertTrue(app.buttons["Tax Receipt"].exists)
        XCTAssertTrue(app.buttons["Clinic Intake Form"].exists)
        XCTAssertTrue(app.buttons["scan-button"].exists)
        XCTAssertTrue(app.buttons["import-button"].exists)

        app.buttons["Contract Packet"].tap()
        XCTAssertTrue(anyElement(id: "scan-page-image").waitForExistence(timeout: 8))
        XCTAssertTrue(anyElement(id: "recognized-text").exists)
        XCTAssertTrue(app.buttons["export-button"].exists)
    }

    func testFixtureLibraryPaywall() {
        launch(reset: true, fixtures: true, paywallPreview: true)

        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence(timeout: 5))
        app.buttons["Upgrade"].tap()
        XCTAssertTrue(anyElement(id: "paywall").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["SaneScan Pro Annual"].exists)
        XCTAssertTrue(app.staticTexts["$29.99/year"].exists)
        XCTAssertTrue(anyElement(id: "subscription-disclosure").exists)
        assertLegalLinksReachable()
        XCTAssertTrue(app.buttons["restore-purchases"].exists)
        XCTAssertTrue(app.buttons["paywall-done"].exists)
    }

    func testLargeTextAccessibilityPrimarySurfaces() {
        launch(reset: true, fixtures: true, paywallPreview: true, largeText: true)

        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["scan-button"].exists)
        XCTAssertTrue(app.buttons["import-button"].exists)
        XCTAssertTrue(app.buttons["Upgrade"].exists)
        XCTAssertTrue(app.buttons["Contract Packet"].exists)
        captureAccessibilityHierarchy("01-large-text-library")

        app.buttons["Contract Packet"].tap()
        XCTAssertTrue(anyElement(id: "scan-page-image").waitForExistence(timeout: 8))
        XCTAssertTrue(anyElement(id: "recognized-text").exists)
        XCTAssertTrue(app.buttons["export-button"].exists)
        XCTAssertTrue(app.buttons["detail-done"].exists)
        captureAccessibilityHierarchy("02-large-text-detail")

        app.buttons["detail-done"].tap()
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence(timeout: 5))
        app.buttons["Upgrade"].tap()
        XCTAssertTrue(anyElement(id: "paywall").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["$29.99/year"].exists)
        XCTAssertTrue(anyElement(id: "subscription-disclosure").exists)
        assertLegalLinksReachable()
        XCTAssertTrue(app.buttons["restore-purchases"].exists)
        captureAccessibilityHierarchy("03-large-text-paywall")
        captureVisualState("07-large-text-paywall")
    }

    func testLaunchPerformance() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            launch(reset: true)
            XCTAssertTrue(app.staticTexts["SaneScan"].waitForExistence(timeout: 8))
            app.terminate()
        }
    }

    func testVisualAuditScreenshots() {
        launch(reset: true)

        XCTAssertTrue(app.staticTexts["SaneScan"].waitForExistence(timeout: 8))
        captureVisualState("01-empty-library")

        app.buttons["import-button"].tap()
        XCTAssertTrue(waitForPhotoPicker())
        RunLoop.current.run(until: Date().addingTimeInterval(2.0))

        launch(reset: true, fixtures: true)

        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        captureVisualState("03-fixture-library")

        app.buttons["Contract Packet"].tap()
        XCTAssertTrue(anyElement(id: "scan-page-image").waitForExistence(timeout: 8))
        captureVisualState("04-document-detail")

        app.buttons["export-button"].tap()
        XCTAssertTrue(waitForShareSheet())
        captureVisualState("05-share-sheet")

        launch(reset: true, fixtures: true, paywallPreview: true)
        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        app.buttons["Upgrade"].tap()
        XCTAssertTrue(anyElement(id: "paywall").waitForExistence(timeout: 5))
        XCTAssertTrue(anyElement(id: "subscription-disclosure").exists)
        assertLegalLinksReachable()
        captureVisualState("06-paywall")
    }

    private func launch(
        reset: Bool = false,
        fixtures: Bool = false,
        paywallPreview: Bool = false,
        largeText: Bool = false
    ) {
        app.launchArguments = []
        if reset {
            app.launchArguments.append("--sanescan-reset-library")
        }
        if fixtures {
            app.launchArguments.append("--sanescan-ui-fixtures")
        }
        if paywallPreview {
            app.launchArguments.append("--sanescan-paywall-preview")
        }
        if largeText {
            app.launchArguments.append("--sanescan-large-text-preview")
        }
        app.launch()
    }

    private func waitForShareSheet() -> Bool {
        let labels = ["Copy", "Save to Files", "Share", "Close", "AirDrop"]
        let deadline = Date().addingTimeInterval(15)
        while Date() < deadline {
            if labels.contains(where: { app.buttons[$0].exists || app.staticTexts[$0].exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return false
    }

    private func waitForPhotoPicker() -> Bool {
        let labels = ["Photos", "Cancel", "Add", "Albums", "Search"]
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            if labels.contains(where: {
                app.buttons[$0].exists || app.staticTexts[$0].exists || app.navigationBars[$0].exists
            }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return false
    }

    private func anyElement(id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    private func assertLegalLinksReachable() {
        if !legalElementExists(id: "terms-of-use-link", label: "Terms of Use") {
            app.swipeUp()
        }
        XCTAssertTrue(waitForLegalElement(id: "terms-of-use-link", label: "Terms of Use", timeout: 3))
        XCTAssertTrue(legalElementExists(id: "privacy-policy-link", label: "Privacy Policy"))
    }

    private func waitForLegalElement(id: String, label: String, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if legalElementExists(id: id, label: label) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        return legalElementExists(id: id, label: label)
    }

    private func legalElementExists(id: String, label: String) -> Bool {
        anyElement(id: id).exists ||
            app.buttons[label].exists ||
            app.links[label].exists ||
            app.staticTexts[label].exists
    }

    private func closeShareSheetIfNeeded() {
        if app.buttons["Close"].exists {
            app.buttons["Close"].tap()
        } else if app.buttons["Cancel"].exists {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
        XCTAssertTrue(app.buttons["detail-done"].waitForExistence(timeout: 5))
    }

    private func captureVisualState(_ name: String) {
        let fallbackDirectory = UIDevice.current.userInterfaceIdiom == .pad
            ? "/tmp/sanescan-visual-audit-ipad"
            : "/tmp/sanescan-visual-audit"
        let directory = ProcessInfo.processInfo.environment["SANESCAN_SCREENSHOT_DIR"].flatMap { value in
            value.isEmpty ? nil : value
        } ?? fallbackDirectory

        do {
            try FileManager.default.createDirectory(
                atPath: directory,
                withIntermediateDirectories: true
            )
            let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).png")
            try XCUIScreen.main.screenshot().pngRepresentation.write(to: url)
        } catch {
            XCTFail("Could not write visual audit screenshot \(name): \(error)")
        }
    }

    private func captureAccessibilityHierarchy(_ name: String) {
        let directory = ProcessInfo.processInfo.environment["SANESCAN_ACCESSIBILITY_DIR"].flatMap { value in
            value.isEmpty ? nil : value
        } ?? "/tmp/sanescan-accessibility-audit"

        do {
            try FileManager.default.createDirectory(
                atPath: directory,
                withIntermediateDirectories: true
            )
            let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name).txt")
            try app.debugDescription.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("Could not write accessibility hierarchy \(name): \(error)")
        }
    }
}
