import Foundation

enum CurrencyCode: String, CaseIterable, Identifiable {
    case BTC
    case ZAR
    case USD
    case AUD
    // Add more as needed

    var id: String { rawValue }

    var symbol: String? {
        guard let symbolEnum = CurrencySymbol(rawValue: rawValue) else { return nil }
        return CurrencySymbols.symbol(for: symbolEnum)
    }

    var name: String? {
        guard let symbolEnum = CurrencySymbol(rawValue: rawValue) else { return nil }
        return CurrencySymbols.name(for: symbolEnum)
    }

    static let supportedCurrencies: [CurrencyCode] = [
        .BTC, .ZAR, .USD, .AUD
        // Add more as needed
    ]
}
