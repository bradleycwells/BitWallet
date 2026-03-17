//
//  BitWalletUITests.swift
//  BitWalletUITests
//
//  Created by Bradley Wells on 2026/03/09.
//

import XCTest

final class BitWalletUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testWelcomeAlertAppearsAndCanBeDismissed() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--reset-defaults")
        app.launch()
        
        // Handle Welcome Alert
        let welcomeAlert = app.alerts["Welcome to BitWallet!"]
        XCTAssertTrue(welcomeAlert.waitForExistence(timeout: 8), "Welcome alert should appear on first launch")
        
        let maybeLaterButton = welcomeAlert.buttons["Maybe Later"]
        XCTAssertTrue(maybeLaterButton.exists, "Maybe Later button should exist")
        
        maybeLaterButton.tap()
        
        XCTAssertFalse(welcomeAlert.exists, "Welcome alert should disappear after tapping Maybe Later")
    }

    @MainActor
    func testEditAmountViaHeader() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--reset-defaults")
        app.launch()
        
        let welcomeAlert = app.alerts["Welcome to BitWallet!"]
        if welcomeAlert.waitForExistence(timeout: 5) {
            let textField = welcomeAlert.textFields.firstMatch
            textField.tap()
            textField.typeText("1.5")
            welcomeAlert.buttons["Get Started"].tap()
        }
        
        let editButton = app.buttons["EditAmountButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5), "Edit button should be visible")
        
        editButton.tap()
        
        let editAlert = app.alerts["Edit Amount"]
        XCTAssertTrue(editAlert.waitForExistence(timeout: 2), "Edit amount alert should appear")
        
        let textField = editAlert.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2))
        textField.tap()
        
        // Ensure the keyboard is present and the field has focus
        if !app.keyboards.element.exists {
            textField.tap()
        }
        
        // Select-all and replace text to avoid partial deletion issues
        textField.doubleTap()
        if app.menuItems["Select All"].waitForExistence(timeout: 1) {
            app.menuItems["Select All"].tap()
        } else {
            // Fallback: press and drag to select the text if the menu doesn't appear
            let start = textField.coordinate(withNormalizedOffset: .init(dx: 0.1, dy: 0.5))
            let end = textField.coordinate(withNormalizedOffset: .init(dx: 0.9, dy: 0.5))
            start.press(forDuration: 0.5, thenDragTo: end)
        }
        textField.typeText("2.5")
        
        editAlert.buttons["Add"].tap()
        
        // Ensure the edit alert is dismissed
        XCTAssertFalse(editAlert.waitForExistence(timeout: 0.5))
        
        let bitcoinAmountText = app.staticTexts["BitcoinAmountText"]
        XCTAssertTrue(bitcoinAmountText.waitForExistence(timeout: 8), "Amount text should be visible")
        
        // Poll until the label reflects the expected numeric value, tolerating formatting/localization
        let end = Date().addingTimeInterval(8)
        var matched = false
        while Date() < end {
            let label = bitcoinAmountText.label
            // Normalize: keep digits, comma, dot, and space
            let normalized = label.replacingOccurrences(of: "[^0-9., ]", with: "", options: .regularExpression)
            if normalized.contains("2.5") || normalized.contains("2,5") || normalized.contains("2.50") || normalized.contains("2,50") {
                matched = true
                break
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }
        XCTAssertTrue(matched, "Label should reflect newly entered amount. Actual: \(app.staticTexts["BitcoinAmountText"].label)")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

