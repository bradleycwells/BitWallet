import Foundation

struct LatestRatesEndpoint: Endpoint {
    let base: CurrencyCode
    let symbols: [CurrencyCode]
    let method: HTTPMethod = .get
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
    private let rateCacheManager: APIRateCacheManager

    init(apiClient: APIClient, token: String, rateCacheManager: APIRateCacheManager = APIRateCacheManager()) {
        self.apiClient = apiClient
        self.token = token
        self.rateCacheManager = rateCacheManager
    }

    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> [CurrencyCode: Double] {
        let endpoint = LatestRatesEndpoint(base: base, symbols: symbols)
        let endpointName = endpoint.path
        let baseCode = base.rawValue
        let symbolCodes = symbols.map { $0.rawValue }

        let ratesDict = try await rateCacheManager.getOrFetchRates(endpoint: endpointName, base: baseCode, symbols: symbolCodes, forceRefresh: forceRefresh) {
            let response: ExchangeRatesResponse = try await apiClient.request(endpoint: endpoint, headerToken: token)
            if let error = response.error {
                throw NetworkError.serverError(statusCode: error.code)
            }
            guard let rates = response.rates else {
                throw NetworkError.decodingFailed(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No rates returned"]))
            }
            return rates
        }

        var result: [CurrencyCode: Double] = [:]
        for code in symbols {
            if let rate = ratesDict[code.rawValue] {
                result[code] = rate
            }
        }
        return result
    }
}
