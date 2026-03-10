import SwiftUI

@main
struct BitWalletApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            WalletView(viewModel: container.makeWalletViewModel())
        }
    }
}
