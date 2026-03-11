import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
    case options = "OPTIONS"
}

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var method: HTTPMethod { .get }
    var url: URL? {
        guard let base = URL(string: AppConfig.apiBaseURL),
              var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else {
            return nil
        }
        let sanitized = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.path = base.path.appending("/\(sanitized)")
        components.queryItems = queryItems
        return components.url
    }
}
