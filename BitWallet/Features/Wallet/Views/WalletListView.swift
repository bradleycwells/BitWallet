import SwiftUI

struct WalletListView: View {
    let currencyValues: [CurrencyValue]
    
    var body: some View {
        List(currencyValues) { value in
            CurrencyRowView(currency: value)
        }
        .listStyle(PlainListStyle())
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
