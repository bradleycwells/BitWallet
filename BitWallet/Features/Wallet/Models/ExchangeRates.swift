import Foundation

struct ExchangeRatesResponse: Decodable {
    let success: Bool?
    let base: String?
    let rates: [String: Double]?
    let error: FixerError?
}

struct FixerError: Decodable {
    let code: Int
    let type: String
    let info: String?
}
