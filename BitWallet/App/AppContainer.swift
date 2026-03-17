import Foundation

@MainActor
final class AppContainer {
    init() {
        // When running UI tests with --reset-defaults, clear the app's UserDefaults so first-launch flows show.
        if ProcessInfo.processInfo.arguments.contains("--reset-defaults") {
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // Core Dependencies
    lazy var apiClient: APIClient = DefaultAPIClient()
    lazy var userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()
    lazy var dateProvider: DateProviding = DateProvider()
    
    // Services
    lazy var fixerService: FixerService = {
        let envToken = ProcessInfo.processInfo.environment["API_TOKEN"]
        // Fallback to AppConfig.apiToken on MainActor if env var is not set
        let token: String = envToken ?? MainActor.assumeIsolated { AppConfig.apiToken }
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
