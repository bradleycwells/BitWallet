import Foundation

protocol UserDefaultsManaging {
    func getBitcoinAmount() -> Double
    func setBitcoinAmount(_ amount: Double)
    func hasCompletedOnboarding() -> Bool
    func setCompletedOnboarding(_ completed: Bool)
    func getSelectedCurrencies() -> [String]
    func setSelectedCurrencies(_ currencies: [String])
    func getLastFetchDate() -> Date?
    func setLastFetchDate(_ date: Date)
}

class UserDefaultsManager: UserDefaultsManaging {
    private let defaults: UserDefaults
    private let btcAmountKey = "com.bitwallet.btcAmount"
    private let onboardingKey = "com.bitwallet.onboardingCompleted"
    private let selectedCurrenciesKey = "com.bitwallet.selectedCurrencies"
    private let lastFetchDateKey = "com.bitwallet.lastFetchDate"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getBitcoinAmount() -> Double {
        return defaults.double(forKey: btcAmountKey)
    }

    func setBitcoinAmount(_ amount: Double) {
        defaults.set(amount, forKey: btcAmountKey)
    }

    func hasCompletedOnboarding() -> Bool {
        return defaults.bool(forKey: onboardingKey)
    }

    func setCompletedOnboarding(_ completed: Bool) {
        defaults.set(completed, forKey: onboardingKey)
    }

    func getSelectedCurrencies() -> [String] {
        return defaults.stringArray(forKey: selectedCurrenciesKey) ?? AppConstants.priorityCurrencies
    }

    func setSelectedCurrencies(_ currencies: [String]) {
        defaults.set(currencies, forKey: selectedCurrenciesKey)
    }

    func getLastFetchDate() -> Date? {
        return defaults.object(forKey: lastFetchDateKey) as? Date
    }

    func setLastFetchDate(_ date: Date) {
        defaults.set(date, forKey: lastFetchDateKey)
    }
}
