import SwiftUI

struct WalletListView: View {
    let currencyValues: [CurrencyValue]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(currencyValues) { value in
                    CurrencyRowView(currency: value)
                        .padding(.horizontal)
                    Divider()
                        .background(Color.brandText.opacity(0.1))
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
    ])
}
