import SwiftUI

struct WalletEmptyStateView: View {
    let onSetAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange.opacity(0.8))
            
            VStack(spacing: 8) {
                Text("Ready to track?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Set your Bitcoin amount to see its value in different currencies.")
                    .font(.body)
                    .foregroundColor(.secondary)
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
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Spacer()
        }
    }
}

#Preview {
    WalletEmptyStateView {
        print("Set Amount tapped")
    }
}
