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

struct FluctuationEndpoint: Endpoint {
    let base: CurrencyCode
    let symbols: [CurrencyCode]
    let startDate: String
    let endDate: String
    let method: HTTPMethod = .get
    var path: String { "fluctuation" }
    
    var queryItems: [URLQueryItem]? {
        let symbolsString = symbols.map { $0.rawValue }.joined(separator: ",")
        return [
            URLQueryItem(name: "base", value: base.rawValue),
            URLQueryItem(name: "symbols", value: symbolsString),
            URLQueryItem(name: "start_date", value: startDate),
            URLQueryItem(name: "end_date", value: endDate)
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

    func fetchFluctuations(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> [CurrencyCode: Double] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        // As per request: start date is today, end date is start of yesterday.
        // Wait, the API documentation usually expects start_date < end_date.
        // User said: "Put the start date as today, and the end date as the start of yesterday."
        // I will interpret this as the range between yesterday and today.
        let startDate = dateFormatter.string(from: yesterday)
        let endDate = dateFormatter.string(from: now)
        
        let endpoint = FluctuationEndpoint(base: base, symbols: symbols, startDate: startDate, endDate: endDate)
        let endpointName = "fluctuation_\(startDate)_\(endDate)"
        let baseCode = base.rawValue
        let symbolCodes = symbols.map { $0.rawValue }

        let fluctuationsDict = try await rateCacheManager.getOrFetchRates(endpoint: endpointName, base: baseCode, symbols: symbolCodes, forceRefresh: forceRefresh) {
            let response: FluctuationResponse = try await apiClient.request(endpoint: endpoint, headerToken: token)
            if let error = response.error {
                throw NetworkError.serverError(statusCode: error.code)
            }
            guard let rates = response.rates else {
                throw NetworkError.decodingFailed(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No fluctuation data returned"]))
            }
            
            var simpleDict: [String: Double] = [:]
            for (key, value) in rates {
                simpleDict[key] = value.change
            }
            return simpleDict
        }

        var result: [CurrencyCode: Double] = [:]
        for code in symbols {
            if let change = fluctuationsDict[code.rawValue] {
                result[code] = change
            }
        }
        return result
    }
}
