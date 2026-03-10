import Foundation

protocol FixerService {
    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode]) async throws -> [CurrencyCode: Double]
}
