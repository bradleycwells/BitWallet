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
    @Published var lastFetchDate: Date?
    
    private let fixerService: FixerService
    private let userDefaultsManager: UserDefaultsManaging
    private var currentRates: [CurrencyCode: Double] = [:]
    private var currentFluctuations: [CurrencyCode: Double] = [:]
    
    @Published var selectedCurrencyCodes: [CurrencyCode] = []
    @Published var currencySearchText: String = ""
    
    init(fixerService: FixerService, userDefaultsManager: UserDefaultsManaging) {
        self.fixerService = fixerService
        self.userDefaultsManager = userDefaultsManager
        
        self.bitcoinAmount = userDefaultsManager.getBitcoinAmount()
        self.isOnboardingCompleted = userDefaultsManager.hasCompletedOnboarding()
        self.selectedCurrencyCodes = userDefaultsManager.getSelectedCurrencies().compactMap { CurrencyCode(rawValue: $0) }
        self.lastFetchDate = userDefaultsManager.getLastFetchDate()
    }
    
    func updateSelectedCurrencies(_ codes: [CurrencyCode]) {
        self.selectedCurrencyCodes = codes
        userDefaultsManager.setSelectedCurrencies(codes.map { $0.rawValue })
        Task {
            await fetchRates(forceRefresh: true)
        }
    }
    
    func fetchRates(forceRefresh: Bool = false) async {
        guard bitcoinAmount > 0 else { return }
        guard !selectedCurrencyCodes.isEmpty else {
            self.currencyValues = []
            return
        }
        
        if !forceRefresh { isLoading = true }
        errorMessage = nil
        do {
            let symbols = selectedCurrencyCodes
            
            async let ratesTask = fixerService.fetchLatestRates(base: .BTC, symbols: symbols, forceRefresh: forceRefresh)
            async let fluctuationsTask = fixerService.fetchFluctuations(base: .BTC, symbols: symbols, forceRefresh: forceRefresh)
            
            let ((rates, ratesDate), (fluctuations, _)) = try await (ratesTask, fluctuationsTask)
            
            self.currentRates = rates
            self.currentFluctuations = fluctuations
            
            self.lastFetchDate = ratesDate
            userDefaultsManager.setLastFetchDate(ratesDate)
            
            calculateValues()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func calculateValues() {
        let priorityOrder = AppConstants.priorityCurrencies
        
        let sortedCodes = selectedCurrencyCodes.sorted { code1, code2 in
            let index1 = priorityOrder.firstIndex(of: code1.rawValue) ?? Int.max
            let index2 = priorityOrder.firstIndex(of: code2.rawValue) ?? Int.max
            
            if index1 != index2 {
                return index1 < index2
            }
            return code1.rawValue < code2.rawValue
        }
        
        var newValues: [CurrencyValue] = []
        for code in sortedCodes {
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
    
    var filteredCurrencies: [CurrencyCode] {
        let allCurrencies = CurrencyCode.allCases.filter { $0 != .BTC }
        let filtered: [CurrencyCode]
        if currencySearchText.isEmpty {
            filtered = allCurrencies
        } else {
            filtered = allCurrencies.filter {
                ($0.name?.localizedCaseInsensitiveContains(currencySearchText) ?? false) ||
                $0.rawValue.localizedCaseInsensitiveContains(currencySearchText)
            }
        }
        
        let priorityOrder = AppConstants.priorityCurrencies
        return filtered.sorted { code1, code2 in
            let index1 = priorityOrder.firstIndex(of: code1.rawValue) ?? Int.max
            let index2 = priorityOrder.firstIndex(of: code2.rawValue) ?? Int.max
            
            if index1 != index2 {
                return index1 < index2
            }
            return code1.rawValue < code2.rawValue
        }
    }
}
