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
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack{
                if let fluctuation = currency.fluctuation {
                    HStack(spacing: 4) {
                        Image(systemName: fluctuation >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 14, weight: .bold))
                        Text(formatPriceChange(fluctuation))
                            .font(.subheadline)
                    }
                    .foregroundColor(fluctuation >= 0 ? .green : .red)
                }
                Text(formatCurrency(currency.totalValue))
                    .font(.title3)
                    .fontWeight(.semibold)
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
#Preview("CurrencyRowView – Samples") {
    VStack(spacing: 12) {
        CurrencyRowView(
            currency: CurrencyValue(
                code: .USD,
                rate: 64123.45,
                totalValue: 0.25 * 64123.45,
                fluctuation: 1.2345
            )
        )
        .padding(.horizontal)
    }
    .padding(.vertical)
    .previewLayout(.sizeThatFits)
}

