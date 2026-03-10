import Foundation

struct LatestRatesEndpoint: Endpoint {
    let base: CurrencyCode
    let symbols: [CurrencyCode]
    
    var path: String { "latest" }
    
    var queryItems: [URLQueryItem]? {
        let symbolsString = symbols.map { $0.rawValue }.joined(separator: ",")
        return [
            URLQueryItem(name: "base", value: base.rawValue),
            URLQueryItem(name: "symbols", value: symbolsString)
        ]
    }
}

class DefaultFixerService: FixerService {
    private let apiClient: APIClient
    private let token: String
    
    init(apiClient: APIClient, token: String) {
        self.apiClient = apiClient
        self.token = token
    }
    
    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode]) async throws -> [CurrencyCode: Double] {
        let endpoint = LatestRatesEndpoint(base: base, symbols: symbols)
        let response: ExchangeRatesResponse = try await apiClient.request(endpoint: endpoint, headerToken: token)
        
        if let error = response.error {
            throw NetworkError.serverError(statusCode: error.code)
        }
        
        guard let rates = response.rates else {
            throw NetworkError.decodingFailed(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No rates returned"]))
        }
        
        var result: [CurrencyCode: Double] = [:]
        for code in symbols {
            if let rate = rates[code.rawValue] {
                result[code] = rate
            }
        }
        return result
    }
}
