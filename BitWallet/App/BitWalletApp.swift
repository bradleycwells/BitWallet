import SwiftUI

@main
struct BitWalletApp: App {
    @State private var showSplash = true
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView(showSplash: $showSplash)
                } else {
                    WalletView(viewModel: container.makeWalletViewModel())
                }
            }
        }
    }
}
