import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The endpoint URL is invalid."
        case .decodingFailed(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code): return "The server returned an error code: \(code)."
        }
    }
}
