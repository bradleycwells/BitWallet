import Foundation

protocol FixerService {
    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> ([CurrencyCode: Double], Date)
    func fetchFluctuations(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> ([CurrencyCode: Double], Date)
}
