import Foundation
@testable import BitWallet

class MockFixerService: FixerService {
    var resultToReturn: Result<[CurrencyCode: Double], Error> = .success([:])
    var fetchedBase: CurrencyCode?
    var fetchedSymbols: [CurrencyCode]?
    
    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode]) async throws -> [CurrencyCode: Double] {
        self.fetchedBase = base
        self.fetchedSymbols = symbols
        
        switch resultToReturn {
        case .success(let rates):
            return rates
        case .failure(let error):
            throw error
        }
    }
}
