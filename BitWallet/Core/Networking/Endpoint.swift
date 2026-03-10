import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
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
