import XCTest
@testable import BitWallet

@MainActor
final class APIRateCacheManagerTests: XCTestCase {
    var cacheManager: APIRateCacheManager!
    var mockDefaults: UserDefaults!
    let suiteName = "APIRateCacheManagerTests"
    
    override func setUp() {
        super.setUp()
        // Use a unique suite name and remove it before Each test to ensure clean state
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = UserDefaults(suiteName: suiteName)
        cacheManager = APIRateCacheManager(defaults: mockDefaults)
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = nil
        cacheManager = nil
        super.tearDown()
    }
    
    func testGetOrFetchRatesReturnsCachedDataWhenAvailableToday() async throws {
        // Arrange
        let endpoint = "latest"
        let base = "BTC"
        let symbols = ["USD", "ZAR"]
        let expectedRates = ["USD": 50000.0, "ZAR": 900000.0]
        
        // Populate cache
        cacheManager.setRates(expectedRates, endpoint: endpoint, base: base, symbols: symbols)
        
        // Act
        var fetchBlockCalled = false
        let rates = try await cacheManager.getOrFetchRates(endpoint: endpoint, base: base, symbols: symbols) {
            fetchBlockCalled = true
            return ["USD": 99999.0] // Different rates that should NOT be returned
        }
        
        // Assert
        XCTAssertFalse(fetchBlockCalled, "Fetch block should not be called when cached data is valid")
        XCTAssertEqual(rates, expectedRates)
    }
    
    func testGetOrFetchRatesCallsFetchBlockWhenCacheIsExpired() async throws {
        // Arrange
        let endpoint = "latest"
        let base = "BTC"
        let symbols = ["USD"]
        let oldRates = ["USD": 40000.0]
        let newRates = ["USD": 50000.0]
        
        // Manually set an old date in the past
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        cacheManager.setRates(oldRates, endpoint: endpoint, base: base, symbols: symbols)
        
        // Override the timestamp to yesterday
        let timestampKey = "com.bitwallet.rates.timestamp.\(endpoint).\(base).\(symbols.joined(separator: ","))"
        mockDefaults.set(yesterday, forKey: timestampKey)
        
        // Act
        var fetchBlockCalled = false
        let rates = try await cacheManager.getOrFetchRates(endpoint: endpoint, base: base, symbols: symbols) {
            fetchBlockCalled = true
            return newRates
        }
        
        // Assert
        XCTAssertTrue(fetchBlockCalled, "Fetch block should be called when cache is expired")
        XCTAssertEqual(rates, newRates)
    }
    
    func testGetOrFetchRatesCallsFetchBlockWhenForcingRefresh() async throws {
        // Arrange
        let endpoint = "latest"
        let base = "BTC"
        let symbols = ["USD"]
        let cachedRates = ["USD": 40000.0]
        let newRates = ["USD": 50000.0]
        
        // Populate cache with current date
        cacheManager.setRates(cachedRates, endpoint: endpoint, base: base, symbols: symbols)
        
        // Act
        var fetchBlockCalled = false
        let rates = try await cacheManager.getOrFetchRates(endpoint: endpoint, base: base, symbols: symbols, forceRefresh: true) {
            fetchBlockCalled = true
            return newRates
        }
        
        // Assert
        XCTAssertTrue(fetchBlockCalled, "Fetch block should be called when forceRefresh is true")
        XCTAssertEqual(rates, newRates)
    }
    
    func testGetOrFetchRatesCachesTheResult() async throws {
        // Arrange
        let endpoint = "latest"
        let base = "BTC"
        let symbols = ["USD"]
        let fetchedRates = ["USD": 50000.0]
        
        // Act
        _ = try await cacheManager.getOrFetchRates(endpoint: endpoint, base: base, symbols: symbols) {
            return fetchedRates
        }
        
        // Assert
        let (cachedRates, cachedDate) = cacheManager.getRates(endpoint: endpoint, base: base, symbols: symbols)
        XCTAssertEqual(cachedRates, fetchedRates)
        XCTAssertNotNil(cachedDate)
        if let cachedDate = cachedDate {
            XCTAssertTrue(Calendar.current.isDateInToday(cachedDate))
        }
    }
}
