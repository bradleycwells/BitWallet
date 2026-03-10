import XCTest
@testable import BitWallet

@MainActor
final class WalletViewModelTests: XCTestCase {
    var viewModel: WalletViewModel!
    var mockFixerService: MockFixerService!
    var mockUserDefaultsManager: MockUserDefaultsManager!
    
    override func setUp() {
        super.setUp()
        mockFixerService = MockFixerService()
        mockUserDefaultsManager = MockUserDefaultsManager()
        
        // Setup initial state
        mockUserDefaultsManager.btcAmount = 2.0
        
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
    
    func testInitializationLoadsSavedBTCAmount() {
        XCTAssertEqual(viewModel.bitcoinAmount, 2.0)
    }
    
    func testFetchRatesSuccessUpdatesCurrencyValues() async {
        // Arrange
        let mockRates: [CurrencyCode: Double] = [
            .zar: 1000000.0,
            .usd: 50000.0
        ]
        mockFixerService.resultToReturn = .success(mockRates)
        
        // Act
        await viewModel.fetchRates()
        
        // Assert
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Because btcAmount is 2.0, the total values should be double the rates
        if let zarValue = viewModel.currencyValues.first(where: { $0.code == .zar }) {
            XCTAssertEqual(zarValue.totalValue, 2000000.0)
        } else {
            XCTFail("ZAR value missing")
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
    
    func testUpdatingBTCAmountRecalculatesValuesAndSaves() async {
        // Arrange
        let mockRates: [CurrencyCode: Double] = [.usd: 50000.0]
        mockFixerService.resultToReturn = .success(mockRates)
        await viewModel.fetchRates()
        
        // Act
        viewModel.bitcoinAmount = 3.0
        
        // Assert
        XCTAssertEqual(mockUserDefaultsManager.btcAmount, 3.0)
        if let usdValue = viewModel.currencyValues.first(where: { $0.code == .usd }) {
            XCTAssertEqual(usdValue.totalValue, 150000.0)
        } else {
            XCTFail("USD value missing")
        }
    }
}
