import Foundation
@testable import BitWallet

class MockUserDefaultsManager: UserDefaultsManaging {
    var btcAmount: Double = 2.0
    var onboardingCompleted: Bool = false
    var selectedCurrencies: [String] = ["USD", "ZAR", "AUD"]
    var lastFetchDate: Date? = nil
    
    func hasCompletedOnboarding() -> Bool {
        return onboardingCompleted
    }
    
    func setCompletedOnboarding(_ completed: Bool) {
        onboardingCompleted = completed
    }
    
    func getSelectedCurrencies() -> [String] {
        return selectedCurrencies
    }
    
    func setSelectedCurrencies(_ currencies: [String]) {
        selectedCurrencies = currencies
    }
    
    func getLastFetchDate() -> Date? {
        return lastFetchDate
    }
    
    func setLastFetchDate(_ date: Date) {
        lastFetchDate = date
    }
    
    func getBitcoinAmount() -> Double {
        return btcAmount
    }
    
    func setBitcoinAmount(_ amount: Double) {
        btcAmount = amount
    }
}
