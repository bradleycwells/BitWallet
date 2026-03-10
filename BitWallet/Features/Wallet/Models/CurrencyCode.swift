import Foundation

enum CurrencyCode: String, CaseIterable, Identifiable {
    case btc = "BTC"
    case zar = "ZAR"
    case usd = "USD"
    case aud = "AUD"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .btc: return "₿"
        case .zar: return "R"
        case .usd: return "$"
        case .aud: return "A$"
        }
    }
}
