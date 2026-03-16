import Foundation

typealias CurrencyCode = CurrencySymbol

extension CurrencyCode {
    static let supportedCurrencies: [CurrencyCode] = CurrencyCode.allCases
}
