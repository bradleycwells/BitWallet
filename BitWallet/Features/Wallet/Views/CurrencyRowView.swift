import SwiftUI

struct CurrencyRowView: View {
    let currency: CurrencyValue
    
    var body: some View {
        HStack {
            Text(currency.code.symbol ?? "...")
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(currency.code.rawValue)
                    .font(.headline)
                Text("Rate: \(formatCurrency(currency.rate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatCurrency(currency.totalValue))
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter.currencyFormatter
        formatter.currencySymbol = currency.code.symbol
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
