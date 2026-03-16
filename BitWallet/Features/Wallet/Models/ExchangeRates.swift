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

struct FluctuationResponse: Decodable {
    let success: Bool?
    let fluctuation: Bool?
    let start_date: String?
    let end_date: String?
    let base: String?
    let rates: [String: FluctuationData]?
    let error: FixerError?
}

struct FluctuationData: Decodable {
    let start_rate: Double
    let end_rate: Double
    let change: Double
    let change_pct: Double
}
