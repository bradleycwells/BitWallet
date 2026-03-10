import Foundation

protocol Endpoint {
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.apilayer.com"
        // Compose the full path here
        components.path = "/fixer/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        components.queryItems = queryItems
        return components.url
    }
}
