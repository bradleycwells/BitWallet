import SwiftUI

struct CurrencyRowView: View {
    let currency: CurrencyValue
    
    var body: some View {
        HStack {
            WSSymbolText(symbol: currency.code.symbol ?? "...")
            
            VStack(alignment: .leading) {
                Text(currency.code.rawValue)
                    .font(.headline)
                    .foregroundColor(.brandText)
                Text("Rate: \(formatCurrency(currency.rate))")
                    .font(.subheadline)
                    .foregroundColor(.brandText.opacity(0.6))
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                if let fluctuation = currency.fluctuation {
                    HStack(spacing: 4) {
                        Image(systemName: fluctuation >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 14, weight: .bold))
                        Text(formatPriceChange(fluctuation))
                            .font(.subheadline)
                    }
                    .foregroundColor(fluctuation >= 0 ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Text(formatCurrency(currency.totalValue))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.brandText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter.currencyFormatter
        formatter.currencySymbol = currency.code.symbol
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    private func formatPriceChange(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

