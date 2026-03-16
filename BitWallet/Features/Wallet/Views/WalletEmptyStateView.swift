import SwiftUI

struct WalletEmptyStateView: View {
    let onSetAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.brandPrimary.opacity(0.8))
            
            VStack(spacing: 8) {
                Text("Ready to track?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.brandText)
                
                Text("Set your Bitcoin amount to see its value in different currencies.")
                    .font(.body)
                    .foregroundColor(.brandText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                onSetAmount()
            } label: {
                Text("Set Amount")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.brandPrimary)
                    .foregroundColor(.black)
                    .cornerRadius(10)
            }
            .shadow(color: .brandPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Spacer()
        }
    }
}

#Preview {
    WalletEmptyStateView {
        print("Set Amount tapped")
    }
}
