import Foundation

@MainActor
final class AppContainer {
    
    // Core Dependencies
    lazy var apiClient: APIClient = DefaultAPIClient()
    lazy var userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()
    lazy var dateProvider: DateProviding = DateProvider()
    
    // Services
    lazy var fixerService: FixerService = {
        let envToken = ProcessInfo.processInfo.environment["API_TOKEN"]
        // Fallback to AppConfig.apiToken on MainActor if env var is not set
        let token: String = envToken ?? (try? MainActor.assumeIsolated { AppConfig.apiToken }) ?? ""
        return DefaultFixerService(apiClient: apiClient, token: token)
    }() // Or load from Plist/Env
    
    // Feature View Models
    func makeWalletViewModel() -> WalletViewModel {
        return WalletViewModel(
            fixerService: fixerService,
            userDefaultsManager: userDefaultsManager
        )
    }
}
