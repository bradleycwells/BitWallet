import Foundation

protocol UserDefaultsManaging {
    func getBitcoinAmount() -> Double
    func setBitcoinAmount(_ amount: Double)
}

class UserDefaultsManager: UserDefaultsManaging {
    private let defaults: UserDefaults
    private let btcAmountKey = "com.bitwallet.btcAmount"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getBitcoinAmount() -> Double {
        return defaults.double(forKey: btcAmountKey)
    }

    func setBitcoinAmount(_ amount: Double) {
        defaults.set(amount, forKey: btcAmountKey)
    }
}
