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
        launch(reset: true, fixtures: true)

        XCTAssertTrue(anyElement(id: "library-view").waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["Upgrade"].waitForExistence(timeout: 5))
        app.buttons["Upgrade"].tap()
        XCTAssertTrue(anyElement(id: "paywall").waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["App Store options loading"].exists)
        XCTAssertTrue(app.buttons["retry-purchases"].exists)
        XCTAssertTrue(anyElement(id: "subscription-disclosure").exists)
        XCTAssertTrue(anyElement(id: "terms-of-use-link").exists)
        XCTAssertTrue(anyElement(id: "privacy-policy-link").exists)
        XCTAssertTrue(app.buttons["restore-purchases"].exists)
        XCTAssertTrue(app.buttons["paywall-done"].exists)
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
        XCTAssertTrue(anyElement(id: "terms-of-use-link").exists)
        XCTAssertTrue(anyElement(id: "privacy-policy-link").exists)
        captureVisualState("06-paywall")
    }

    private func launch(reset: Bool = false, fixtures: Bool = false, paywallPreview: Bool = false) {
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
}
