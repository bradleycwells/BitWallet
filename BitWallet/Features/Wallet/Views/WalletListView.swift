import SwiftUI

struct WalletListView: View {
    let currencyValues: [CurrencyValue]
    let lastFetchDate: Date?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(currencyValues) { value in
                    CurrencyRowView(currency: value)
                        .padding(.horizontal)
                    Divider()
                        .background(Color.brandText.opacity(0.1))
                }
                
                if let lastFetch = lastFetchDate {
                    Text("Last updated: \(lastFetch.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.brandText.opacity(0.4))
                        .padding(.vertical, 20)
                }
            }
        }
    }
}

#Preview {
    WalletListView(currencyValues: [
        CurrencyValue(
            code: .USD,
            rate: 65000.0,
            totalValue: 0.5 * 65000.0,
            fluctuation: -1.23
        ),
        CurrencyValue(
            code: .ZAR,
            rate: 60000.0,
            totalValue: 0.25 * 60000.0,
            fluctuation: 0.45
        )
    ], lastFetchDate: Date())
}
