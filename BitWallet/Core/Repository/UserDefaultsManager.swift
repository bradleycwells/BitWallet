import Foundation

protocol UserDefaultsManaging {
    func getBitcoinAmount() -> Double
    func setBitcoinAmount(_ amount: Double)
    func hasCompletedOnboarding() -> Bool
    func setCompletedOnboarding(_ completed: Bool)
}

class UserDefaultsManager: UserDefaultsManaging {
    private let defaults: UserDefaults
    private let btcAmountKey = "com.bitwallet.btcAmount"
    private let onboardingKey = "com.bitwallet.onboardingCompleted"

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
}
