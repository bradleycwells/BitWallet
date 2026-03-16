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
        CurrencyValue(code: "USD", name: "US Dollar", value: 65000.0, rate: 65000.0),
        CurrencyValue(code: "EUR", name: "Euro", value: 60000.0, rate: 60000.0)
    ])
}
