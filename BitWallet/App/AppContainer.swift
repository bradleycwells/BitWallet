import Foundation

@MainActor
final class AppContainer {
    
    // Core Dependencies
    lazy var apiClient: APIClient = DefaultAPIClient()
    lazy var userDefaultsManager: UserDefaultsManaging = UserDefaultsManager()
    lazy var dateProvider: DateProviding = DateProvider()
    
    // Services
    lazy var fixerService: FixerService = DefaultFixerService(apiClient: apiClient, token: "w1rfB3DxJFoA2k6VekUyXKkffz3YRtNj") // Or load from Plist/Env
    
    // Feature View Models
    func makeWalletViewModel() -> WalletViewModel {
        return WalletViewModel(
            fixerService: fixerService,
            userDefaultsManager: userDefaultsManager
        )
    }
}
