import SwiftUI

struct WalletHeaderView: View {
    let bitcoinAmount: Double
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Bitcoin")
                .font(.headline)
                .foregroundColor(.brandText.opacity(0.7))
            
            HStack {
                Text("₿")
                    .font(.largeTitle)
                    .foregroundColor(.brandPrimary)
                
                Text(bitcoinAmount, format: .number)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.brandText)
                    .onTapGesture {
                        onEdit()
                    }
                    .accessibilityIdentifier("BitcoinAmountText")

                
                Spacer()
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.brandPrimary)
                }
                .accessibilityIdentifier("EditAmountButton")
            }
            .padding()
            .background(Color.brandText.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

#Preview {
    WalletHeaderView(bitcoinAmount: 1.23456789) {
        print("Edit tapped")
    }
}
