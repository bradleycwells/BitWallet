import SwiftUI

struct WalletHeaderView: View {
    let bitcoinAmount: Double
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Bitcoin")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("₿")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Text(bitcoinAmount, format: .number)
                    .font(.system(size: 34, weight: .bold))
                
                Spacer()
                
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
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
