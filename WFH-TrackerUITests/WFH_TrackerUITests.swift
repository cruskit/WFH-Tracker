//
//  WFH_TrackerUITests.swift
//  WFH-TrackerUITests
//
//  Created by Paul Ruskin on 29/6/2025.
//

import XCTest

final class WFH_TrackerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    // MARK: - App Store Screenshots

    func testTakeScreenshots() throws {
        let outDir = URL(fileURLWithPath: "/tmp/wfh-screenshots", isDirectory: true)
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

        func capture(_ name: String) throws {
            let png = XCUIScreen.main.screenshot().pngRepresentation
            try png.write(to: outDir.appendingPathComponent("\(name).png"))
        }

        func launch() -> XCUIApplication {
            let app = XCUIApplication()
            app.launchEnvironment["WFH_SCREENSHOT_MODE"] = "1"
            app.launch()
            return app
        }

        // ── Session 1: Log view + Entry sheet + Split entry ────────────────
        var app = launch()

        // 1. Log view — calendar with a full month of coloured data
        Thread.sleep(forTimeInterval: 2.0)
        try capture("01_log_calendar")

        // 2. Entry sheet — tap today (Jun 10, seeded as Office) to open the week form
        app.buttons.matching(NSPredicate(format: "label CONTAINS '10: '")).firstMatch.tap()
        Thread.sleep(forTimeInterval: 1.0)
        try capture("02_log_entry_sheet")

        // 3. Split entry — tap "Advanced entry" for Thursday Jun 11 (4th row, seeded as 4h home + 4h office)
        // Rows are Mon=0, Tue=1, Wed=2, Thu=3 (0-indexed)
        app.buttons.matching(NSPredicate(format: "label == 'Advanced entry'")).element(boundBy: 3).tap()
        Thread.sleep(forTimeInterval: 1.0)
        try capture("03_split_entry")

        // ── Session 2: Export + Settings ──────────────────────────────────
        app = launch()
        Thread.sleep(forTimeInterval: 1.5)

        // 4. Export view
        app.tabBars.buttons["Export"].tap()
        Thread.sleep(forTimeInterval: 1.0)
        try capture("04_export")

        // 5. Settings view
        app.tabBars.buttons["Settings"].tap()
        Thread.sleep(forTimeInterval: 0.8)
        try capture("05_settings")
    }
}
