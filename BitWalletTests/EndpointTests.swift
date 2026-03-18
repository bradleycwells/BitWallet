import XCTest
@testable import BitWallet

final class EndpointTests: XCTestCase {
    
    struct TestEndpoint: Endpoint {
        var path: String
        var queryItems: [URLQueryItem]?
    }
    
    func testURLConstructionWithNoQueryItems() {
        let endpoint = TestEndpoint(path: "/latest", queryItems: nil)
        let url = endpoint.url
        
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/latest") ?? false)
    }
    
    func testURLConstructionWithQueryItems() {
        let endpoint = TestEndpoint(path: "latest", queryItems: [
            URLQueryItem(name: "base", value: "BTC"),
            URLQueryItem(name: "symbols", value: "USD,ZAR")
        ])
        let url = endpoint.url
        
        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("base=BTC") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("symbols=USD,ZAR") ?? false)
    }
    
    func testURLSanitizationOfPath() {
        let endpoint = TestEndpoint(path: "//latest/", queryItems: nil)
        let url = endpoint.url
        
        XCTAssertNotNil(url)
        // It should result in .../latest and not ...//latest/
        // We check the last component or that it doesn't have trailing slash
        XCTAssertFalse(url?.absoluteString.hasSuffix("/") ?? true)
    }
}
