import XCTest
@testable import BitWallet

final class DefaultFixerServiceTests: XCTestCase {
    var service: DefaultFixerService!
    var mockAPIClient: MockAPIClient!
    var mockCacheManager: APIRateCacheManager!
    var mockDefaults: UserDefaults!
    let suiteName = "DefaultFixerServiceTests"
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = UserDefaults(suiteName: suiteName)!
        mockAPIClient = MockAPIClient()
        mockCacheManager = APIRateCacheManager(defaults: mockDefaults)
        service = DefaultFixerService(apiClient: mockAPIClient, token: "test_token", rateCacheManager: mockCacheManager)
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = nil
        mockAPIClient = nil
        mockCacheManager = nil
        service = nil
        super.tearDown()
    }
    
    func testFetchLatestRatesSuccess() async throws {
        // Arrange
        let rates = ["USD": 50000.0, "EUR": 45000.0]
        let response = ExchangeRatesResponse(success: true, base: "BTC", rates: rates, error: nil)
        mockAPIClient.responseToReturn = response
        
        // Act
        let (result, _) = try await service.fetchLatestRates(base: .BTC, symbols: [.USD, .EUR], forceRefresh: true)
        
        // Assert
        XCTAssertEqual(result[.USD], 50000.0)
        XCTAssertEqual(result[.EUR], 45000.0)
        XCTAssertEqual(mockAPIClient.requestCount, 1)
    }
    
    func testFetchLatestRatesReturnsErrorFromResponse() async {
        // Arrange
        let fixerError = FixerError(code: 101, type: "invalid_access_key", info: "Invalid API Key")
        let response = ExchangeRatesResponse(success: false, base: nil, rates: nil, error: fixerError)
        mockAPIClient.responseToReturn = response
        
        // Act & Assert
        do {
            _ = try await service.fetchLatestRates(base: .BTC, symbols: [.USD], forceRefresh: true)
            XCTFail("Should have thrown an error")
        } catch NetworkError.serverError(let code) {
            XCTAssertEqual(code, 101)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testFetchFluctuationsSuccess() async throws {
        // Arrange
        let fluctuationData = ["USD": FluctuationData(start_rate: 49000.0, end_rate: 50000.0, change: 1000.0, change_pct: 2.04)]
        let response = FluctuationResponse(success: true, fluctuation: true, start_date: "2024-01-01", end_date: "2024-01-02", base: "BTC", rates: fluctuationData, error: nil)
        mockAPIClient.responseToReturn = response
        
        // Act
        let (result, _) = try await service.fetchFluctuations(base: .BTC, symbols: [.USD], forceRefresh: true)
        
        // Assert
        XCTAssertEqual(result[.USD], 1000.0)
        XCTAssertEqual(mockAPIClient.requestCount, 1)
    }
}

class MockAPIClient: APIClient {
    var responseToReturn: Any?
    var errorToThrow: Error?
    var requestCount = 0
    
    func request<T>(endpoint: Endpoint, headerToken: String) async throws -> T where T : Decodable {
        requestCount += 1
        if let error = errorToThrow {
            throw error
        }
        if let response = responseToReturn as? T {
            return response
        }
        throw NetworkError.decodingFailed(NSError(domain: "MockAPIClient", code: 0, userInfo: nil))
    }
}
