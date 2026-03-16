import SwiftUI

struct WalletErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(errorMessage)
                .foregroundColor(.brandText)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(.brandPrimary)
        }
    }
}

#Preview {
    WalletErrorView(errorMessage: "Failed to connect to the server. Please check your internet connection.") {
        print("Retry tapped")
    }
}
