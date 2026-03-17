import XCTest
@testable import BitWallet

final class CurrencySymbolTests: XCTestCase {
    
    func testCurrencySymbolIDIsRawValue() {
        XCTAssertEqual(CurrencySymbol.USD.id, "USD")
        XCTAssertEqual(CurrencySymbol.ZAR.id, "ZAR")
    }
    
    func testCurrencySymbolNameLookup() {
        XCTAssertEqual(CurrencySymbol.USD.name, "United States Dollar")
        XCTAssertEqual(CurrencySymbol.ZAR.name, "South African Rand")
        XCTAssertEqual(CurrencySymbol.BTC.name, "Bitcoin")
    }
    
    func testCurrencySymbolSymbolLookup() {
        XCTAssertEqual(CurrencySymbol.USD.symbol, "$")
        XCTAssertEqual(CurrencySymbol.ZAR.symbol, "R")
        XCTAssertEqual(CurrencySymbol.BTC.symbol, "₿")
        XCTAssertEqual(CurrencySymbol.EUR.symbol, "€")
    }
    
    func testAllSupportedCurrenciesArePresent() {
        // Just a smoke test to ensure things aren't empty
        XCTAssertGreaterThan(CurrencyCode.supportedCurrencies.count, 100)
    }
    
    func testCurrencySymbolsConsistency() {
        // Ensure every case in CurrencySymbol has a name and a symbol mapping
        for code in CurrencySymbol.allCases {
            XCTAssertNotNil(code.name, "Missing name for \(code.rawValue)")
            XCTAssertNotNil(code.symbol, "Missing symbol for \(code.rawValue)")
        }
    }
}
