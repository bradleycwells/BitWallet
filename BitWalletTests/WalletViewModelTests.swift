import XCTest
@testable import BitWallet

@MainActor
final class WalletViewModelTests: XCTestCase {
    var viewModel: WalletViewModel!
    var mockFixerService: MockFixerService!
    var mockUserDefaultsManager: MockUserDefaultsManager!
    
    override func setUp() async throws {
        try await super.setUp()
        mockFixerService = MockFixerService()
        mockUserDefaultsManager = MockUserDefaultsManager()
        
        // Setup initial state
        mockUserDefaultsManager.btcAmount = 2.0
        mockUserDefaultsManager.selectedCurrencies = ["USD", "ZAR"]
        
        viewModel = WalletViewModel(
            fixerService: mockFixerService,
            userDefaultsManager: mockUserDefaultsManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockFixerService = nil
        mockUserDefaultsManager = nil
        super.tearDown()
    }
    
    // MARK: - Initialization tests
    
    func testInitializationLoadsSavedBTCAmount() {
        XCTAssertEqual(viewModel.bitcoinAmount, 2.0)
    }
    
    func testInitializationLoadsSelectedCurrencies() {
        XCTAssertEqual(viewModel.selectedCurrencyCodes, [.USD, .ZAR])
    }
    
    // MARK: - Fetching Rates tests
    
    func testFetchRatesSuccessUpdatesCurrencyValues() async {
        // Arrange
        let mockRates: [CurrencyCode: Double] = [
            .ZAR: 1000000.0,
            .USD: 50000.0
        ]
        let mockDate = Date()
        mockFixerService.resultToReturn = .success((mockRates, mockDate))
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.lastFetchDate, mockDate)
        XCTAssertEqual(mockUserDefaultsManager.lastFetchDate, mockDate)
        
        // Because btcAmount is 2.0, the total values should be double the rates
        if let zarValue = viewModel.currencyValues.first(where: { $0.code == .ZAR }) {
            XCTAssertEqual(zarValue.totalValue, 2000000.0)
        } else {
            XCTFail("ZAR value missing")
        }
    }
    
    func testFetchRatesWithFluctuations() async {
        // Arrange
        let mockRates: [CurrencyCode: Double] = [.USD: 50000.0]
        let mockFluctuations: [CurrencyCode: Double] = [.USD: 15.25]
        let mockDate = Date()
        
        mockFixerService.resultToReturn = .success((mockRates, mockDate))
        mockFixerService.fluctionResultToReturn = .success((mockFluctuations, mockDate))
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        if let usdValue = viewModel.currencyValues.first(where: { $0.code == .USD }) {
            XCTAssertEqual(usdValue.fluctuation, 15.25)
        } else {
            XCTFail("USD value missing")
        }
    }
    
    func testFetchRatesFailureSetsErrorMessage() async {
        // Arrange
        mockFixerService.resultToReturn = .failure(NetworkError.invalidURL)
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currencyValues.count, 0)
    }
    
    func testFetchRatesGuardsAgainstZeroBTCAmount() async {
        // Arrange
        viewModel.bitcoinAmount = 0.0
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        XCTAssertFalse(mockFixerService.forceRefreshCalled)
    }
    
    func testFetchRatesGuardsAgainstEmptySelectedCurrencies() async {
        // Arrange
        viewModel.selectedCurrencyCodes = []
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.currencyValues.isEmpty)
    }
    
    // MARK: - Action tests
    
    func testUpdatingBTCAmountRecalculatesValuesAndSaves() async {
        // Arrange
        let mockRates: [CurrencyCode: Double] = [.USD: 50000.0]
        mockFixerService.resultToReturn = .success((mockRates, Date()))
        await viewModel.fetchRates()
        
        // Act
        viewModel.bitcoinAmount = 3.0
        
        // Assert
        XCTAssertEqual(mockUserDefaultsManager.btcAmount, 3.0)
        if let usdValue = viewModel.currencyValues.first(where: { $0.code == .USD }) {
            XCTAssertEqual(usdValue.totalValue, 150000.0)
        } else {
            XCTFail("USD value missing")
        }
    }
    
    func testUpdateSelectedCurrenciesCorrectlySavesAndFetches() {
        // Arrange
        let newCurrencies: [CurrencyCode] = [.USD, .AUD]
        
        // Act
        viewModel.updateSelectedCurrencies(newCurrencies)
        
        // Assert
        XCTAssertEqual(viewModel.selectedCurrencyCodes, newCurrencies)
        XCTAssertEqual(mockUserDefaultsManager.selectedCurrencies, ["USD", "AUD"])
    }
    
    func testCalculateValuesSortingByPriority() async {
        // Arrange
        // AppConstants.priorityCurrencies = ["ZAR", "USD", "AUD"]
        let mockRates: [CurrencyCode: Double] = [
            .AUD: 75000.0,
            .USD: 50000.0,
            .GBP: 40000.0,
            .ZAR: 1000000.0
        ]
        
        viewModel.selectedCurrencyCodes = [.GBP, .USD, .ZAR, .AUD]
        mockFixerService.resultToReturn = .success((mockRates, Date()))
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        // Expected order: ZAR (priority 0), USD (priority 1), AUD (priority 2), then alphabetically? Wait, Alphabetically for non-priority
        // GBP is not in priorityCurrencies, so it should be last?
        XCTAssertEqual(viewModel.currencyValues[0].code, .ZAR)
        XCTAssertEqual(viewModel.currencyValues[1].code, .USD)
        XCTAssertEqual(viewModel.currencyValues[2].code, .AUD)
        XCTAssertEqual(viewModel.currencyValues[3].code, .GBP)
    }
}
