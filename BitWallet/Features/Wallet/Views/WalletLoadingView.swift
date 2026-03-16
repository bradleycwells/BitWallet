import SwiftUI

struct WalletLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView("Fetching rates...")
            Spacer()
        }
    }
}

#Preview {
    WalletLoadingView()
}
