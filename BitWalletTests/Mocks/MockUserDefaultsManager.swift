import Foundation
@testable import BitWallet

class MockUserDefaultsManager: UserDefaultsManaging {
    func hasCompletedOnboarding() -> Bool {
        <#code#>
    }
    
    func setCompletedOnboarding(_ completed: Bool) {
        <#code#>
    }
    
    func getSelectedCurrencies() -> [String] {
        <#code#>
    }
    
    func setSelectedCurrencies(_ currencies: [String]) {
        <#code#>
    }
    
    func getLastFetchDate() -> Date? {
        <#code#>
    }
    
    func setLastFetchDate(_ date: Date) {
        <#code#>
    }
    
    
    var btcAmount: Double = 1.0
    
    func getBitcoinAmount() -> Double {
        return btcAmount
    }
    
    func setBitcoinAmount(_ amount: Double) {
        btcAmount = amount
    }
}
