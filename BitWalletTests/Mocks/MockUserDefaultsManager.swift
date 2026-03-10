import Foundation
@testable import BitWallet

class MockUserDefaultsManager: UserDefaultsManaging {
    var btcAmount: Double = 1.0
    
    func getBitcoinAmount() -> Double {
        return btcAmount
    }
    
    func setBitcoinAmount(_ amount: Double) {
        btcAmount = amount
    }
}
