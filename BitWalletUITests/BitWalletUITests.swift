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
        XCTAssertTrue(welcomeAlert.waitForExistence(timeout: 5), "Welcome alert should appear on first launch")
        
        let maybeLaterButton = welcomeAlert.buttons["Maybe Later"]
        XCTAssertTrue(maybeLaterButton.exists, "Maybe Later button should exist")
        
        maybeLaterButton.tap()
        
        XCTAssertFalse(welcomeAlert.exists, "Welcome alert should disappear after tapping Maybe Later")
    }

    @MainActor
    func testWelcomeAlertGetStarted() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--reset-defaults")
        app.launch()
        
        let welcomeAlert = app.alerts["Welcome to BitWallet!"]
        XCTAssertTrue(welcomeAlert.waitForExistence(timeout: 5), "Welcome alert should appear on first launch")
        
        let textField = welcomeAlert.textFields.firstMatch
        textField.tap()
        textField.typeText("1.5")
        
        let getStartedButton = welcomeAlert.buttons["Get Started"]
        getStartedButton.tap()
        
        let bitcoinAmountText = app.staticTexts["BitcoinAmountText"]
        XCTAssertTrue(bitcoinAmountText.waitForExistence(timeout: 5), "Amount text should be visible")
        XCTAssertTrue(bitcoinAmountText.label.contains("1.5"), "Label should reflect entered amount")
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
        textField.tap()
        
        // Delete previous text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 5)
        textField.typeText(deleteString)
        textField.typeText("2.5")
        
        editAlert.buttons["Add"].tap()
        
        let bitcoinAmountText = app.staticTexts["BitcoinAmountText"]
        XCTAssertTrue(bitcoinAmountText.waitForExistence(timeout: 2), "Amount text should be visible")
        XCTAssertTrue(bitcoinAmountText.label.contains("2.5"), "Label should reflect newly entered amount")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
