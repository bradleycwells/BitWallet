import SwiftUI
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var bitcoinAmount: Double = 0.0 {
        didSet {
            userDefaultsManager.setBitcoinAmount(bitcoinAmount)
            if bitcoinAmount > 0 && !isOnboardingCompleted {
                setOnboardingCompleted()
            }
            calculateValues()
            HapticManager.shared.triggerSuccess()
        }
    }
    
    @Published var currencyValues: [CurrencyValue] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOnboardingCompleted: Bool = false
    
    private let fixerService: FixerService
    private let userDefaultsManager: UserDefaultsManaging
    private var currentRates: [CurrencyCode: Double] = [:]
    private var currentFluctuations: [CurrencyCode: Double] = [:]
    
    init(fixerService: FixerService, userDefaultsManager: UserDefaultsManaging) {
        self.fixerService = fixerService
        self.userDefaultsManager = userDefaultsManager
        
        self.bitcoinAmount = userDefaultsManager.getBitcoinAmount()
        self.isOnboardingCompleted = userDefaultsManager.hasCompletedOnboarding()
    }
    
    func fetchRates(forceRefresh: Bool = false) async {
        guard bitcoinAmount > 0 else { return }
        
        if !forceRefresh { isLoading = true }
        errorMessage = nil
        do {
            let symbols: [CurrencyCode] = [.ZAR, .USD, .AUD]
            
            async let ratesTask = fixerService.fetchLatestRates(base: .BTC, symbols: symbols, forceRefresh: forceRefresh)
            async let fluctuationsTask = fixerService.fetchFluctuations(base: .BTC, symbols: symbols, forceRefresh: forceRefresh)
            
            let (rates, fluctuations) = try await (ratesTask, fluctuationsTask)
            
            self.currentRates = rates
            self.currentFluctuations = fluctuations
            calculateValues()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func calculateValues() {
        var newValues: [CurrencyValue] = []
        for code in [CurrencyCode.ZAR, CurrencyCode.USD, CurrencyCode.AUD] {
            if let rate = currentRates[code] {
                let total = rate * bitcoinAmount
                let fluctuation = currentFluctuations[code]
                newValues.append(CurrencyValue(code: code, rate: rate, totalValue: total, fluctuation: fluctuation))
            }
        }
        self.currencyValues = newValues
    }
    
    func setOnboardingCompleted() {
        isOnboardingCompleted = true
        userDefaultsManager.setCompletedOnboarding(true)
    }
}
