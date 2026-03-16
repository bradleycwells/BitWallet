import Foundation
@testable import BitWallet

class MockFixerService: FixerService {
    var resultToReturn: Result<[CurrencyCode: Double], Error> = .success([:])
    var fetchedBase: CurrencyCode?
    var fetchedSymbols: [CurrencyCode]?
    
    func fetchLatestRates(base: BitWallet.CurrencyCode, symbols: [BitWallet.CurrencyCode], forceRefresh: Bool) async throws -> [BitWallet.CurrencyCode : Double] {
        self.fetchedBase = base
        self.fetchedSymbols = symbols
        
        switch resultToReturn {
        case .success(let rates):
            return rates
        case .failure(let error):
            throw error
        }
    }
    
    func fetchFluctuations(base: CurrencyCode, symbols: [CurrencyCode], forceRefresh: Bool) async throws -> [CurrencyCode: Double] {
        switch resultToReturn {
        case .success(let rates):
            return rates
        case .failure(let error):
            throw error
        }
    }
}
