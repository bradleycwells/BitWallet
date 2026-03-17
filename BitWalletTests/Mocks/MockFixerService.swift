import Foundation
@testable import BitWallet

class MockFixerService: FixerService {
    var resultToReturn: Result<([CurrencyCode: Double], Date), Error> = .success(([:], Date()))
    var fluctionResultToReturn: Result<([CurrencyCode: Double], Date), Error> = .success(([:], Date()))
    
    var fetchedBase: CurrencyCode?
    var fetchedSymbols: [CurrencyCode]?
    var forceRefreshCalled: Bool = false
    
    func fetchLatestRates(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> ([CurrencyCode: Double], Date) {
        self.fetchedBase = base
        self.fetchedSymbols = symbols
        self.forceRefreshCalled = forceRefresh
        
        switch resultToReturn {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func fetchFluctuations(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> ([CurrencyCode: Double], Date) {
        switch fluctionResultToReturn {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
