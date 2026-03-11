import Foundation

// Lightweight protocols to read HTTP method from Endpoint without reflection
private protocol HasHTTPMethodString { var httpMethod: String? { get } }
private protocol HasHTTPMethodEnum { associatedtype HTTPMethodEnum: RawRepresentable where HTTPMethodEnum.RawValue == String; var method: HTTPMethodEnum? { get } }

protocol APIClient {
    func request<T: Decodable>(endpoint: Endpoint, headerToken: String) async throws -> T
}

class DefaultAPIClient: APIClient {
    func request<T>(endpoint: Endpoint, headerToken: String) async throws -> T where T : Decodable {
        // If no header token provided, fallback to AppConfig.apiToken from MainActor
        let resolvedToken: String = headerToken.isEmpty ? await MainActor.run { AppConfig.apiToken } : headerToken
        
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(resolvedToken, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Use HTTP method from Endpoint, default to GET
        request.httpMethod = endpoint.method.rawValue
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}

