import SwiftUI
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var bitcoinAmount: Double = 1.0 {
        didSet {
            userDefaultsManager.setBitcoinAmount(bitcoinAmount)
            calculateValues()
        }
    }
    
    @Published var currencyValues: [CurrencyValue] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let fixerService: FixerService
    private let userDefaultsManager: UserDefaultsManaging
    private var currentRates: [CurrencyCode: Double] = [:]
    
    init(fixerService: FixerService, userDefaultsManager: UserDefaultsManaging) {
        self.fixerService = fixerService
        self.userDefaultsManager = userDefaultsManager
        
        self.bitcoinAmount = userDefaultsManager.getBitcoinAmount()
    }
    
    func fetchRates() async {
        isLoading = true
        errorMessage = nil
        do {
            let rates = try await fixerService.fetchLatestRates(base: .btc, symbols: [.zar, .usd, .aud])
            self.currentRates = rates
            calculateValues()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func calculateValues() {
        var newValues: [CurrencyValue] = []
        for code in [CurrencyCode.zar, CurrencyCode.usd, CurrencyCode.aud] {
            if let rate = currentRates[code] {
                let total = rate * bitcoinAmount
                newValues.append(CurrencyValue(code: code, rate: rate, totalValue: total))
            }
        }
        self.currencyValues = newValues
    }
}
