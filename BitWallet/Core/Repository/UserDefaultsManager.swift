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
        let amount = defaults.double(forKey: btcAmountKey)
        return amount > 0 ? amount : 1.0 // Default to 1 BTC if not set
    }

    func setBitcoinAmount(_ amount: Double) {
        defaults.set(amount, forKey: btcAmountKey)
    }
}
