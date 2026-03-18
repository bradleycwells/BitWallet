import Foundation

class APIRateCacheManager {
    private let defaults: UserDefaults
    /// Cache expiration interval in seconds (default: 24 hours)
    private let cacheExpirationInterval: TimeInterval

    init(defaults: UserDefaults = .standard, cacheExpirationInterval: TimeInterval = 86400) {
        self.defaults = defaults
        self.cacheExpirationInterval = cacheExpirationInterval
    }
    
    private func ratesKey(for endpoint: String, base: String, symbols: [String]) -> String {
        let symbolsString = symbols.sorted().joined(separator: ",")
        return "com.bitwallet.rates.\(endpoint).\(base).\(symbolsString)"
    }
    private func ratesTimestampKey(for endpoint: String, base: String, symbols: [String]) -> String {
        let symbolsString = symbols.sorted().joined(separator: ",")
        return "com.bitwallet.rates.timestamp.\(endpoint).\(base).\(symbolsString)"
    }
    
    func getRates(endpoint: String, base: String, symbols: [String]) -> ([String: Double]?, Date?) {
        let key = ratesKey(for: endpoint, base: base, symbols: symbols)
        let timestampKey = ratesTimestampKey(for: endpoint, base: base, symbols: symbols)
        let rates = defaults.dictionary(forKey: key) as? [String: Double]
        let timestamp = defaults.object(forKey: timestampKey) as? Date
        return (rates, timestamp)
    }
    
    func setRates(_ rates: [String: Double], endpoint: String, base: String, symbols: [String]) {
        let key = ratesKey(for: endpoint, base: base, symbols: symbols)
        defaults.set(rates, forKey: key)
        let timestampKey = ratesTimestampKey(for: endpoint, base: base, symbols: symbols)
        defaults.set(Date(), forKey: timestampKey)
    }
    
    func getOrFetchRates(endpoint: String, base: String, symbols: [String], forceRefresh: Bool = false, fetchBlock: () async throws -> [String: Double]) async throws -> ([String: Double], Date) {
        if !forceRefresh {
            let (cachedRates, cachedDate) = getRates(endpoint: endpoint, base: base, symbols: symbols)
            if let cachedRates = cachedRates, let cachedDate = cachedDate {
                if cachedDate.timeIntervalSinceNow > -cacheExpirationInterval {
                    return (cachedRates, cachedDate)
                }
            }
        }
        let rates = try await fetchBlock()
        let now = Date()
        setRates(rates, endpoint: endpoint, base: base, symbols: symbols)
        return (rates, now)
    }
}
