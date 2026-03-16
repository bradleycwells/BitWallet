import Foundation

struct CurrencyValue: Identifiable, Equatable {
    let id = UUID()
    let code: CurrencyCode
    let rate: Double
    let totalValue: Double
    let fluctuation: Double?
}
