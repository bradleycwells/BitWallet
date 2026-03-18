import XCTest

final class CurrencySelectionUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--reset-defaults")
        app.launch()
        
        // Handle Welcome Alert if it shows up (first launch)
        let welcomeAlert = app.alerts["Welcome to BitWallet!"]
        if welcomeAlert.waitForExistence(timeout: 5) {
            welcomeAlert.buttons["Maybe Later"].tap()
        }
        
        // Wait for splash screen to disappear and Main Wallet view to appear
        let addButton = app.buttons["AddCurrencyButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10), "Add Currency button should appear after splash")
    }

    func testOpenCurrencySelection() {
        app.buttons["AddCurrencyButton"].tap()
        
        XCTAssertTrue(app.navigationBars["Select Currencies"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["CurrencySelectionSaveButton"].exists)
        XCTAssertTrue(app.buttons["CurrencySelectionCancelButton"].exists)
    }

    func testSearchCurrency() {
        app.buttons["AddCurrencyButton"].tap()
        
        let searchField = app.searchFields["Search currencies"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        
        searchField.tap()
        searchField.typeText("South African") // Name for ZAR
        
        XCTAssertTrue(app.buttons["CurrencyRow_ZAR"].exists)
        // USD should be hidden
        XCTAssertFalse(app.buttons["CurrencyRow_USD"].exists)
    }
}
