import XCTest
@testable import BitWallet

final class UserDefaultsManagerTests: XCTestCase {
    var userDefaultsManager: UserDefaultsManager!
    var mockDefaults: UserDefaults!
    let suiteName = "UserDefaultsManagerTests"
    
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = UserDefaults(suiteName: suiteName)!
        userDefaultsManager = UserDefaultsManager(defaults: mockDefaults)
    }
    
    override func tearDown() {
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        mockDefaults = nil
        userDefaultsManager = nil
        super.tearDown()
    }
    
    func testGetBitcoinAmountDefaultsToZero() {
        XCTAssertEqual(userDefaultsManager.getBitcoinAmount(), 0.0)
    }
    
    func testSetAndGetBitcoinAmount() {
        userDefaultsManager.setBitcoinAmount(1.23)
        XCTAssertEqual(userDefaultsManager.getBitcoinAmount(), 1.23)
    }
    
    func testHasCompletedOnboardingDefaultsToFalse() {
        XCTAssertFalse(userDefaultsManager.hasCompletedOnboarding())
    }
    
    func testSetAndHasCompletedOnboarding() {
        userDefaultsManager.setCompletedOnboarding(true)
        XCTAssertTrue(userDefaultsManager.hasCompletedOnboarding())
    }
    
    func testGetSelectedCurrenciesDefaultsToPriorityCurrencies() {
        XCTAssertEqual(userDefaultsManager.getSelectedCurrencies(), AppConstants.priorityCurrencies)
    }
    
    func testSetAndGetSelectedCurrencies() {
        let currencies = ["EUR", "GBP"]
        userDefaultsManager.setSelectedCurrencies(currencies)
        XCTAssertEqual(userDefaultsManager.getSelectedCurrencies(), currencies)
    }
    
    func testGetLastFetchDateDefaultsToNil() {
        XCTAssertNil(userDefaultsManager.getLastFetchDate())
    }
    
    func testSetAndGetLastFetchDate() {
        let date = Date()
        userDefaultsManager.setLastFetchDate(date)
        
        // Use timeIntervalSinceReferenceDate to compare with precision
        if let saveFetchedDate = userDefaultsManager.getLastFetchDate()?.timeIntervalSinceReferenceDate{
            XCTAssertEqual(saveFetchedDate,
                           date.timeIntervalSinceReferenceDate,
                           accuracy: 0.001)
        }
    }
}
